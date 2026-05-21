--BF－星影のノートゥング
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合发动。给与对方800伤害。那之后，对方场上1只表侧表示怪兽的攻击力·守备力下降800。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「黑羽」怪兽召唤。
function c95040215.initial_effect(c)
	-- 为这张卡添加同调召唤手续（调整+调整以外的怪兽1只以上）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合发动。给与对方800伤害。那之后，对方场上1只表侧表示怪兽的攻击力·守备力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,95040215)
	e1:SetTarget(c95040215.target)
	e1:SetOperation(c95040215.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「黑羽」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95040215,0))  --"使用「黑羽-星影之苦剑鸟」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 限制额外召唤的怪兽必须是「黑羽」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x33))
	c:RegisterEffect(e2)
end
-- ①效果的发动准备，设置伤害的对象玩家和数值，并注册伤害操作信息
function c95040215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的对象参数为800
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为给与对方800伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- ①效果的处理，给与对方伤害，之后使对方场上1只表侧表示怪兽的攻击力·守备力下降800
function c95040215.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家伤害，并判断是否成功造成伤害
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择对方场上1只表侧表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果，使之后的攻击力·守备力下降处理与伤害处理不视为同时进行
			Duel.BreakEffect()
			-- 对方场上1只表侧表示怪兽的攻击力·守备力下降800
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-800)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end
