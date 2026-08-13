--宝玉獣 アメジスト・キャット
-- 效果：
-- ①：这张卡可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c32933942.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c32933942.repcon)
	e1:SetOperation(c32933942.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 那次直接攻击给与对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(c32933942.rdcon)
	-- 将该效果的值设为修改对方所受战斗伤害为一半的闭包函数，实现‘给与对方的战斗伤害变成一半’。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 效果②的适用条件：这张卡表侧表示且在怪兽区域，并且因破坏而去墓地的场合。
function c32933942.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 处理②的效果：将这张卡变更为永续魔法卡（TYPE_SPELL+TYPE_CONTINUOUS），使其可以以永续魔法卡的形式表侧表示放置在魔法与陷阱区域。
function c32933942.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- e3的发动条件：这张卡正在进行直接攻击（攻击目标为空），且本卡身上的直接攻击效果不足2个，并且对方场上有怪兽存在。
function c32933942.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 攻击目标为空，即这张卡正在对玩家进行直接攻击。
	return Duel.GetAttackTarget()==nil
		-- 并且这张卡拥有的直接攻击效果数量小于2（没有其他额外赋予的直接攻击效果），且对方场上有怪兽。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
