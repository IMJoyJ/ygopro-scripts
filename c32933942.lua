--宝玉獣 アメジスト・キャット
-- 效果：
-- ①：这张卡可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c32933942.initial_effect(c)
	-- 表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c32933942.repcon)
	e1:SetOperation(c32933942.repop)
	c:RegisterEffect(e1)
	-- 这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 那次直接攻击给与对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(c32933942.rdcon)
	-- 设置效果使对方受到的战斗伤害变为一半。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 判断卡片是否为表侧表示、在怪兽区域、且因破坏而离场。
function c32933942.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将卡片类型改变为永续魔法卡。
function c32933942.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将卡片类型改变为永续魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 判断是否为直接攻击且攻击方场上存在怪兽。
function c32933942.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判断当前攻击目标是否为空。
	return Duel.GetAttackTarget()==nil
		-- 判断此卡已获得的直接攻击效果数量小于2且己方怪兽区域存在怪兽。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
