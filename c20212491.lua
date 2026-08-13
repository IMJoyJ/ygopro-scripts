--ストレイ・ピュアリィ・ストリート
-- 效果：
-- ①：自己场上的「纯爱妖精」怪兽在特殊召唤的回合不会成为对方的效果的对象。
-- ②：1回合1次，自己场上的表侧表示的「纯爱妖精」超量怪兽因对方从场上离开的场合发动。从自己的卡组·墓地选1只1星「纯爱妖精」怪兽特殊召唤。
-- ③：双方的结束阶段，以场上1只「纯爱妖精」超量怪兽为对象才能发动。从自己的卡组·墓地选1张「纯爱妖精」速攻魔法卡在那只怪兽下面重叠作为超量素材。
local s,id,o=GetID()
-- 创建并注册场地魔法卡的各个效果：e1允许发动，e2给纯爱妖精怪兽提供特殊召唤回合不受对方效果对象的抗性，e3在纯爱妖精超量怪兽因对方离场时从卡组·墓地特殊召唤1星纯爱妖精，e4在结束阶段取对象并把纯爱妖精速攻魔法叠放为超量素材。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「纯爱妖精」怪兽在特殊召唤的回合不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	-- 设置『不会成为对方的效果的对象』的判定函数，使满足条件的怪兽获得抗性。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上的表侧表示的「纯爱妖精」超量怪兽因对方从场上离开的场合发动。从自己的卡组·墓地选1只1星「纯爱妖精」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：双方的结束阶段，以场上1只「纯爱妖精」超量怪兽为对象才能发动。从自己的卡组·墓地选1张「纯爱妖精」速攻魔法卡在那只怪兽下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"补充超量素材"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetTarget(s.mattg)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)
end
-- 定义①的抗性对象筛选：c是「纯爱妖精」怪兽且处于本回合特殊召唤状态。
function s.immtg(e,c)
	return c:IsSetCard(0x18c) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 定义②的离场怪兽筛选：曾是己方场上表侧表示的「纯爱妖精」超量怪兽，因对方玩家（非规则原因）从主要怪兽区离场。
function s.spcfilter(c,tp)
	return c:IsSetCard(0x18c) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp and c:IsType(TYPE_XYZ)
		and not c:IsReason(REASON_RULE)
end
-- ②的发动条件：离场怪兽组中存在至少1只满足s.spcfilter的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
-- 定义特殊召唤对象筛选：是「纯爱妖精」1星怪兽且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18c) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动时点：无额外条件；设置本次特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，标明将从卡组·墓地特殊召唤1只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤处理：确认有可用怪兽区；提示选择；从卡组·墓地选出符合条件的1只1星「纯爱妖精」怪兽并表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区空格数，不足则无法特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	-- 显示选择提示，让己方玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组·墓地选择1只满足s.spfilter且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义超量素材候选筛选：可作为超量素材的「纯爱妖精」速攻魔法卡。
function s.matfilter2(c)
	return c:IsCanOverlay() and c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0x18c)
end
-- 定义③的对象筛选：场上表侧表示的「纯爱妖精」超量怪兽，且己方卡组·墓地存在至少1张符合条件的速攻魔法可叠放。
function s.matfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ)
		-- 附加判断：己方卡组·墓地存在至少1张可作为超量素材的「纯爱妖精」速攻魔法卡。
		and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
end
-- ③的发动/目标选择：检查对象是否合法（场上纯爱妖精超量怪兽且存在可叠素材），并选择1只场上怪兽作为对象。
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc,tp) end
	-- 发动时检查：场上存在至少1只满足对象条件的纯爱妖精超量怪兽且可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 显示选择提示，让己方玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只场上符合条件的「纯爱妖精」超量怪兽作为效果对象，并记录为连锁对象。
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 效果处理：取得对象，若对象仍与连锁相关且不免疫此效果，则从卡组·墓地选择1张「纯爱妖精」速攻魔法卡叠放作为超量素材。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 显示选择提示，让己方玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己的卡组·墓地选择1张满足条件的「纯爱妖精」速攻魔法卡（不受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.matfilter2),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tc)
		if #g>0 then
			-- 将选择的速攻魔法卡重叠到对象超量怪兽下面作为超量素材。
			Duel.Overlay(tc,g)
		end
	end
end
