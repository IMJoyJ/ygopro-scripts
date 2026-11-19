--神碑の鬣スレイプニル
-- 效果：
-- 「神碑」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段以及对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡直到结束阶段除外。
-- ②：对方从卡组把卡加入手卡的场合才能发动。在自己场上把1只「神碑衍生物」（天使族·光·4星·攻/守1500）攻击表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置融合召唤手续，并注册暂时除外的①效果与生成衍生物的②效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 定义融合召唤素材条件：需要2只「神碑」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段以及对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方从卡组把卡加入手卡的场合才能发动。在自己场上把1只「神碑衍生物」（天使族·光·4星·攻/守1500）攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
-- ①效果的发动时机判断函数：确认当前处于自己回合的主要阶段1/2，或处于对方回合的战斗阶段
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local tn=Duel.GetTurnPlayer()
	-- 获取当前的决斗阶段
	local ph=Duel.GetCurrentPhase()
	return (tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2))
		or (tn==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤条件函数：筛选场上表侧表示且可以被除外的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- ①效果的目标选择与检查函数：确认这张卡自身可除外且对方场上存在可成为对象的表侧表示怪兽，选择1只对方怪兽作为对象并登记2张卡除外的信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	local c=e:GetHandler()
	-- 发动条件检查：确认这张卡自身可以被除外，且对方场上存在至少1只符合条件的表侧表示怪兽
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了「怪兽除外」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向玩家发送选择提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方怪兽区选择1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(c)
	-- 向系统登记操作信息：将会除外对象怪兽和这张卡共2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- ①效果的处理函数：将对象怪兽和这张卡暂时除外，并在结束阶段注册将它们返回场上的处理
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象选择的对方怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	local g=Group.FromCards(tc,c)
	-- 以暂时除外的方式将两只怪兽除外，并确认至少有1只成功留在除外区
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		-- 获取刚才实际被暂时除外且当前位于除外区的怪兽组
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		-- 遍历被暂时除外的怪兽组，为每只怪兽打上用于结束阶段归还追踪的标记
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()
		-- 直到结束阶段除外。 ②：对方从卡组把卡加入手卡的场合才能发动。在自己场上把1只「神碑衍生物」（天使族·光·4星·攻/守1500）攻击表示特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 为玩家注册在当前回合结束阶段触发的归还怪兽效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件函数：检查怪兽是否仍带有本次暂时除外记录的标记
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
-- 结束阶段归还条件检查函数：若追踪卡片组已无带标记的卡则释放分组并重置效果，否则返回允许归还
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end
-- 结束阶段归还处理函数：将所有带标记的被暂时除外怪兽依次返回各自原来的场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.retfilter,nil)
	-- 遍历需要返回场上的被暂时除外怪兽
	for tc in aux.Next(g) do
		-- 将被暂时除外的怪兽返回其原本的场上
		Duel.ReturnToField(tc)
	end
end
-- 过滤条件函数：筛选由指定玩家控制且是从卡组加入手卡的卡
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- ②效果的发动条件函数：判断本次加入手卡事件中是否存在对方从卡组加入手卡的卡
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- ②效果的发动检查与操作信息设置函数：检查怪兽区空位以及玩家能否特召「神碑衍生物」，并登记相关操作信息
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否以表侧攻击表示特殊召唤「神碑衍生物」（天使族·光·4星·攻/守1500）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x17f,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示发动了「召唤衍生物」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向系统登记操作信息：将会生成1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记操作信息：将会为自己特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ②效果的处理函数开头：再次确认场上仍有空位且可以特殊召唤指定衍生物，否则终止处理
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否已无空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否因限制而无法特殊召唤该衍生物，若无法则结束处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x17f,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then return end
	-- 为自己创建1只「神碑衍生物」卡片实例
	local tk=Duel.CreateToken(tp,id+o)
	-- 将创建的「神碑衍生物」以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
