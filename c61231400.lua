--炎神機－紫龍
-- 效果：
-- 这张卡可以把1只怪兽解放作召唤。这个方法召唤的场合，自己在每次结束阶段受到1000分伤害。这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c61231400.initial_effect(c)
	-- 这张卡可以把1只怪兽解放作召唤。这个方法召唤的场合，自己在每次结束阶段受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61231400,0))  --"把1只怪兽解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c61231400.otcon)
	e1:SetOperation(c61231400.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 定义该召唤规则效果的适用条件：当c为空时放行以便系统查询；否则要求该怪兽等级为7以上、需要解放的数量不超过1，且场上存在1只可解放的怪兽，才能以解放1只怪兽的方式上级召唤。
function c61231400.otcon(e,c,minc)
	if c==nil then return true end
	-- 判断怪兽等级不低于7、所需祭品数不超过1且场上存在1只可用祭品，满足则允许进行单祭品召唤。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 执行召唤操作：选择1只祭品作为召唤素材并解放，完成上级召唤；同时为这张卡注册一个结束阶段给控制者造成1000点伤害的诱发效果。
function c61231400.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从玩家场上选择1只怪兽作为上级召唤的祭品。
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 以召唤和素材为由解放选中的祭品怪兽，完成召唤手续。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	-- 这个方法召唤的场合，自己在每次结束阶段受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61231400,1))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c61231400.damtg)
	e1:SetOperation(c61231400.damop)
	e1:SetReset(RESET_EVENT+0xc6e0000)
	c:RegisterEffect(e1)
end
-- 伤害效果的发动条件检测：无特殊条件即通过，并设置伤害对象为这张卡的控制者tp、伤害数值为1000，同时登记伤害效果信息。
function c61231400.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁对象玩家设置为tp，即由这张卡的控制者自己受到伤害。
	Duel.SetTargetPlayer(tp)
	-- 将连锁参数设置为1000，表示要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本连锁将造成1000点效果伤害，对象为tp，用于其他卡的效果响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 实际处理伤害：确认这张卡仍在场上且表侧表示后，根据链上记录的玩家和数值对其造成伤害。
function c61231400.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 从当前连锁信息中取出之前设定的对象玩家p和伤害数值d。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 对玩家p造成d点效果伤害，即让该玩家受到1000点伤害。
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
