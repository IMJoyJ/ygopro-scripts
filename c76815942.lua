--LL－インディペンデント・ナイチンゲール
-- 效果：
-- 「抒情歌鸲-聚集夜莺」＋「抒情歌鸲」怪兽
-- ①：原本卡名包含「抒情歌鸲」的超量怪兽作为素材让这张卡融合召唤成功的场合才能发动。这张卡的等级上升那些怪兽持有的超量素材数量的数值。
-- ②：这张卡的攻击力上升这张卡的等级×500，这张卡不受其他卡的效果影响。
-- ③：1回合1次，自己主要阶段才能发动。给与对方这张卡的等级×500伤害。
function c76815942.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：以1只「抒情歌鸲-聚集夜莺」和1只「抒情歌鸲」怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,48608796,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf7),1,true,true)
	-- ①：原本卡名包含「抒情歌鸲」的超量怪兽作为素材让这张卡融合召唤成功的场合才能发动。这张卡的等级上升那些怪兽持有的超量素材数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76815942,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c76815942.lvcon)
	e1:SetOperation(c76815942.lvop)
	c:RegisterEffect(e1)
	-- ①：原本卡名包含「抒情歌鸲」的超量怪兽作为素材让这张卡融合召唤成功的场合才能发动。这张卡的等级上升那些怪兽持有的超量素材数量的数值。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c76815942.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	-- 这张卡不受其他卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c76815942.efilter)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升这张卡的等级×500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c76815942.atkval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。给与对方这张卡的等级×500伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(76815942,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(c76815942.damtg)
	e4:SetOperation(c76815942.damop)
	c:RegisterEffect(e4)
end
-- 过滤并获取作为融合素材的、原本卡名包含「抒情歌鸲」的超量怪兽所持有的超量素材数量。
function c76815942.matval(c)
	if c:IsOriginalSetCard(0xf7) and c:IsType(TYPE_XYZ) then
		return c:GetOverlayCount()
	end
	return 0
end
-- 检查融合素材，计算所有符合条件的超量素材数量之和，并将其作为Label保存在效果e1中。
function c76815942.valcheck(e,c)
	local val=c:GetMaterial():GetSum(c76815942.matval)
	e:GetLabelObject():SetLabel(val)
end
-- 确认这张卡是融合召唤成功，且作为素材的「抒情歌鸲」超量怪兽持有的超量素材数量大于0。
function c76815942.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
-- 融合召唤成功时效果的处理：使这张卡的等级上升保存的超量素材数量数值。
function c76815942.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级上升那些怪兽持有的超量素材数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤不受影响的效果，返回true表示不受除自身以外的其他卡片效果影响。
function c76815942.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 计算并返回这张卡攻击力上升的数值，即当前等级乘以500。
function c76815942.atkval(e,c)
	return c:GetLevel()*500
end
-- 伤害效果的发动准备：设置对方玩家为目标，并向系统宣告造成等同于这张卡等级乘以500的伤害操作。
function c76815942.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果处理的目标玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理信息，分类为伤害，目标玩家为对方，伤害数值为这张卡的等级乘以500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetLevel()*500)
end
-- 伤害效果的实际处理：获取目标玩家，并对其造成等同于这张卡等级乘以500的伤害。
function c76815942.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取当前连锁中设定的目标玩家。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 依效果对目标玩家造成等同于这张卡等级乘以500的伤害。
		Duel.Damage(p,c:GetLevel()*500,REASON_EFFECT)
	end
end
