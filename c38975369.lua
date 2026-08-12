--軍荼利
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡和同调怪兽进行战斗的场合，不进行伤害计算，那只怪兽和这张卡回到持有者手卡。
function c38975369.initial_effect(c)
	-- 为卡片添加在召唤或反转成功后的结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤，返回假值表示不能特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡和同调怪兽进行战斗的场合，不进行伤害计算，那只怪兽和这张卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38975369,0))  --"返回手牌"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(c38975369.thcon)
	e4:SetTarget(c38975369.thtg)
	e4:SetOperation(c38975369.thop)
	c:RegisterEffect(e4)
end
-- 判断战斗中的对方怪兽是否为同调怪兽且表侧表示
function c38975369.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsType(TYPE_SYNCHRO)
end
-- 设置战斗开始时的效果处理目标为参与战斗的双方怪兽
function c38975369.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取参与战斗的攻击怪兽和防守怪兽并组成组
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	-- 设置连锁操作信息，指定将怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理战斗结束时将参与战斗的怪兽送回手牌的操作
function c38975369.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 获取当前战斗中的攻击怪兽
	local c=Duel.GetAttacker()
	if c:IsRelateToBattle() then g:AddCard(c) end
	-- 获取当前战斗中的防守怪兽
	c=Duel.GetAttackTarget()
	if c~=nil and c:IsRelateToBattle() then g:AddCard(c) end
	if g:GetCount()>0 then
		-- 将指定怪兽组以效果原因送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
