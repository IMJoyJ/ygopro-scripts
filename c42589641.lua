--星輝士 トライヴェール
-- 效果：
-- 4星「星骑士」怪兽×3
-- 把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。
-- ①：这张卡超量召唤的场合发动。场上的其他卡全部回到手卡。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方手卡随机1张送去墓地。
-- ③：持有超量素材的这张卡被送去墓地的场合，以自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c42589641.initial_effect(c)
	-- 给这张卡添加超量召唤的召唤手续：以3只4星且满足c42589641.xyzfilter条件的「星骑士」怪兽为素材进行超量召唤；xyzfilter额外要求素材控制者本回合没有特殊召唤过非「星骑士」怪兽。
	aux.AddXyzProcedure(c,c42589641.xyzfilter,4,3)
	c:EnableReviveLimit()
	-- 把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c42589641.regcon)
	e1:SetOperation(c42589641.regop)
	c:RegisterEffect(e1)
	-- 把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。（实现为特殊召唤条件：非超量召唤允许，超量召唤时需目标玩家本回合无非「星骑士」特殊召唤记录）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c42589641.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡超量召唤的场合发动。场上的其他卡全部回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42589641,0))  --"回到手卡"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c42589641.thcon)
	e3:SetTarget(c42589641.thtg)
	e3:SetOperation(c42589641.thop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方手卡随机1张送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42589641,1))  --"手卡破坏"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c42589641.hdcost)
	e4:SetTarget(c42589641.hdtg)
	e4:SetOperation(c42589641.hdop)
	c:RegisterEffect(e4)
	-- ③：持有超量素材的这张卡被送去墓地的场合，以自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42589641,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCondition(c42589641.spcon)
	e5:SetTarget(c42589641.sptg)
	e5:SetOperation(c42589641.spop)
	c:RegisterEffect(e5)
	if not c42589641.global_check then
		c42589641.global_check=true
		-- 把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。（全局监听特殊召唤，记录非星骑士特招，供素材和召唤条件判断）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c42589641.checkop)
		-- 将全局监听效果ge1注册到游戏环境中（玩家0），之后任何玩家特殊召唤成功都会触发checkop，用于记录本回合是否有非「星骑士」怪兽被特殊召唤。
		Duel.RegisterEffect(ge1,0)
	end
end
-- checkop：遍历这次特殊召唤成功的怪兽，若存在非「星骑士」怪兽，则根据其召唤玩家给对应玩家注册一个本回合的flag标记，表示该玩家本回合特殊召唤过非「星骑士」怪兽。
function c42589641.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if not tc:IsSetCard(0x9c) then
			if tc:IsSummonPlayer(0) then p1=true else p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若玩家0（自己）本回合特殊召唤过非「星骑士」怪兽，则给玩家0注册编号42589641的flag标记，持续到结束阶段。
	if p1 then Duel.RegisterFlagEffect(0,42589641,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1（对方）本回合特殊召唤过非「星骑士」怪兽，则给玩家1注册编号42589641的flag标记，持续到结束阶段。
	if p2 then Duel.RegisterFlagEffect(1,42589641,RESET_PHASE+PHASE_END,0,1) end
end
-- xyzfilter：超量召唤素材过滤函数，要求素材怪兽是「星骑士」，且其控制者本回合没有特殊召唤过非「星骑士」怪兽（flag为0）。
function c42589641.xyzfilter(c)
	-- 返回true当且仅当素材怪兽属于「星骑士」且其控制者本回合没有非「星骑士」特殊召唤记录。
	return Duel.GetFlagEffect(c:GetControler(),42589641)==0 and c:IsSetCard(0x9c)
end
-- regcon：该效果的触发条件，判断这张卡是以超量召唤方式特殊召唤成功。
function c42589641.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- regop：在超量召唤成功时，给这张卡的控制者注册一个场地效果：本回合不能特殊召唤非「星骑士」怪兽。
function c42589641.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应卡片效果原文：4星「星骑士」怪兽×3。把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。①：这张卡超量召唤的场合发动。场上的其他卡全部回到手卡。②：1回合1次，把这张卡1个超量素材取除才能发动。对方手卡随机1张送去墓地。③：持有超量素材的这张卡被送去墓地的场合，以自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42589641.sumlimit)
	-- 将新创建的‘不能特殊召唤非「星骑士」怪兽’的场地效果e1注册给当前玩家tp，使其本回合受到此自肃限制。
	Duel.RegisterEffect(e1,tp)
end
-- sumlimit：自肃效果的具体过滤条件，当被特殊召唤的怪兽不是「星骑士」时返回true，即禁止该特殊召唤。
function c42589641.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9c)
end
-- splimit：这张卡的特殊召唤条件判断：非超量召唤时允许特殊召唤；超量召唤时若目标玩家本回合没有非「星骑士」特殊召唤记录则允许，否则禁止。
function c42589641.splimit(e,se,sp,st,spos,tgp)
	-- 返回允许特殊召唤当且仅当本次召唤不是超量召唤，或者目标玩家本回合没有非「星骑士」特殊召唤flag。
	return bit.band(st,SUMMON_TYPE_XYZ)~=SUMMON_TYPE_XYZ or Duel.GetFlagEffect(tgp,42589641)==0
end
-- thcon：①效果的触发条件，即这张卡超量召唤成功。
function c42589641.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- thtg：①效果发动时的目标与操作信息设置：收集场上除这张卡外所有可加入手卡的卡，并设置操作信息为回手卡。
function c42589641.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除这张卡自身以外所有可以加入手卡的卡，作为①效果可能回手的对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置①效果的操作信息：分类为回手卡，涉及卡组为g，数量为g的数量，供其他卡连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- thop：①效果处理：将场上除这张卡外的所有可加入手卡的卡全部送回持有者手卡。
function c42589641.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在①效果处理时重新获取场上除这张卡外的所有可加入手卡的卡（因为可能之间卡片信息有变化）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将选中的卡全部以效果原因送回持有者手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
-- hdcost：②效果的发动代价：从这张卡上取除1个超量素材作为COST；检查时确认存在至少1个素材可去除。
function c42589641.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- hdtg：②效果的发动条件与操作信息：对方手卡至少有1张，随后设置操作信息为从对方手卡将1张卡送去墓地。
function c42589641.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认对方手卡数量不为0，这是②效果的发动条件之一。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 end
	-- 设置②效果的操作信息：分类为送去墓地，对象为对方手卡中的1张卡（具体哪张在效果处理时随机决定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- hdop：②效果处理：从对方手卡中随机选择1张，将其送去墓地。
function c42589641.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的全部卡。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选中的1张对方手卡以效果原因送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
-- spcon：③效果的触发条件：这张卡从场上被送去墓地时，离场前场上状态下拥有超量素材，且离场前位于怪兽区。
function c42589641.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousOverlayCountOnField()>0 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- spfilter：③效果可选对象的过滤条件：墓地中的「星骑士」怪兽且能够被当前效果特殊召唤。
function c42589641.spfilter(c,e,tp)
	return c:IsSetCard(0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg：③效果的发动目标选择：需要自己场上有空余怪兽区，且墓地存在至少1只符合条件的「星骑士」怪兽，然后选择其中1只为对象。
function c42589641.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42589641.spfilter(chkc,e,tp) end
	-- 发动时检查自己场上有空余的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只满足特殊召唤条件的「星骑士」怪兽可以作为对象。
		and Duel.IsExistingTarget(c42589641.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家tp发送选择提示消息，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从自己墓地的符合条件的「星骑士」怪兽中选择1只作为③效果的对象。
	local g=Duel.SelectTarget(tp,c42589641.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置③效果的操作信息：分类为特殊召唤，对象为选择的卡g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop：③效果处理：将作为对象的墓地怪兽特殊召唤到自己场上（表侧攻击表示）。
function c42589641.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果处理时的对象卡（之前选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的怪兽区（经由正常特殊召唤手续，检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
