--軍荼利
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡和同调怪兽进行战斗的场合，不进行伤害计算，那只怪兽和这张卡回到持有者手卡。
function c38975369.initial_effect(c)
	-- 为这张卡添加灵魂怪兽效果：在通常召唤成功或反转的回合的结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为 false，使这张卡永远不能满足特殊召唤条件，从而禁止任何特殊召唤。
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
-- 判断这张卡的战斗对象是否存在且为表侧表示的同调怪兽，满足条件时战斗相关效果才会触发。
function c38975369.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsType(TYPE_SYNCHRO)
end
-- 效果发动时，将攻击怪兽和攻击对象作为回手牌的对象登记到操作信息中，并设定回手牌的分类与数量。
function c38975369.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前攻击怪兽和攻击对象组成一个卡片组，作为可能回手牌的对象集合。
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	-- 设置本次连锁的处理信息：效果分类为回手牌，处理对象为上述两组卡片，数量为组内卡片数，玩家参数为0。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时，将仍与本次战斗关联的攻击怪兽和攻击对象加入回手牌组，只要组内有卡就全部送回持有者手卡（以此实现不进行伤害计算）。
function c38975369.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 取得当前攻击怪兽，用于检查是否仍与战斗相关并加入回手牌对象组。
	local c=Duel.GetAttacker()
	if c:IsRelateToBattle() then g:AddCard(c) end
	-- 取得当前被攻击的怪兽（可能为 nil），用于检查是否仍与战斗相关并加入回手牌对象组。
	c=Duel.GetAttackTarget()
	if c~=nil and c:IsRelateToBattle() then g:AddCard(c) end
	if g:GetCount()>0 then
		-- 将符合条件的战斗双方卡片以效果原因送回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
