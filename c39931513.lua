--天盃龍パイドラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1张「灿幻」魔法·陷阱卡加入手卡或在自己场上盖放。
-- ②：只要这张卡在怪兽区域存在，自己的龙族·炎属性怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 为卡片注册全部效果：e1/e2实现①效果（召唤·特殊召唤时检索并加入手卡或盖放「灿幻」魔法·陷阱卡，1回合1次），e3实现②效果（只要此卡在怪兽区域存在，自己的龙族·炎属性怪兽战斗伤害变成0），e4实现③效果（双方战斗阶段1回合1次，以包含此卡的己方场上怪兽为素材进行同调召唤）。
function c39931513.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1张「灿幻」魔法·陷阱卡加入手卡或在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的龙族·炎属性怪兽的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.target)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50091196,1))  --"同调召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.sccon)
	e4:SetTarget(s.sctarg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end
-- 定义①效果的检索过滤条件：所选卡必须是「灿幻」字段的魔法·陷阱卡，并且能够加入手卡或在场上盖放。
function s.thfilter(c)
	if not (c:IsSetCard(0x1a9) and c:IsType(TYPE_SPELL+TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 效果①的发动条件判定与提示：在发动时检查卡组是否存在满足检索条件的「灿幻」魔法·陷阱卡（有才能发动），并在此后向对方玩家提示己方选择了“检索”效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点（chk==0）确认卡组中是否存在至少1张满足s.thfilter条件的「灿幻」魔法·陷阱卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家（1-tp）发送己方选择了“检索”效果的提示信息。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))  --"检索"
end
-- 效果①的处理：让己方从卡组选1张「灿幻」魔法·陷阱卡；如果该卡可加入手卡且（不能盖放或玩家选择“加入手卡”），则加入手卡并向对方展示，否则将该卡在自己场上盖放。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要操作的卡”的提示，引导玩家从卡组选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让己方玩家从卡组选择1张满足s.thfilter条件的「灿幻」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 判断所选卡是否加入手卡：当它能加入手卡，且（不能盖放或玩家选择“加入手卡”选项）时，走加入手卡分支，否则走盖放分支。
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			-- 将选中的「灿幻」魔法·陷阱卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示被加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的「灿幻」魔法·陷阱卡在己方场上里侧表示盖放。
			Duel.SSet(tp,tc)
		end
	end
end
-- 定义②效果的适用对象：当卡片是炎属性且龙族时，其战斗发生的对己方战斗伤害变为0。
function s.target(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON)
end
-- 效果③的发动条件：当前阶段处于战斗阶段（PHASE_BATTLE_START到PHASE_BATTLE之间），即自己或对方的战斗阶段。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于后续判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 效果③的目标检查：确认额外卡组中存在能用这张卡作为调整进行同调召唤的怪兽；并在可发动时向对方提示“同调召唤”，同时设置特殊召唤的操作信息。
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时点检查额外卡组中是否存在至少1只能够以这张卡为调整素材进行同调召唤的怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 向对方玩家发送己方发动了“同调召唤”效果的提示。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"同调召唤"
	-- 设置操作信息：本效果将进行特殊召唤，预定从己方额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的处理：确认这张卡仍在己方场上且与效果关联，然后从额外卡组选择1只可用此卡作为调整的同调怪兽并进行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有能够以这张卡作为调整素材进行同调召唤的怪兽集合。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择同调召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为调整，让己方玩家对选择的同调怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
