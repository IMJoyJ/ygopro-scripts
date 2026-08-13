--ブリザード・プリンセス
-- 效果：
-- 这张卡可以把1只魔法师族怪兽解放表侧攻击表示上级召唤。这张卡召唤成功的回合，对方不能把魔法·陷阱卡发动。
function c28348537.initial_effect(c)
	-- 这张卡可以把1只魔法师族怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28348537,0))  --"把1只魔法师族怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c28348537.otcon)
	e1:SetOperation(c28348537.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功的回合，对方不能把魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c28348537.actlimit)
	c:RegisterEffect(e2)
end
-- 筛选可作为解放素材的魔法师族怪兽：是我方场上的魔法师族怪兽（不限表示形式），或者表侧表示在场的魔法师族怪兽（可以是对方场上的）。
function c28348537.otfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义该卡的上级召唤规则条件：这张卡等级为7以上、所需解放数不超过1，且当前存在1只可用的魔法师族怪兽作为祭品；若c为nil则在规则询问时直接通过。
function c28348537.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取以tp视角看双方场上满足otfilter条件的魔法师族怪兽，作为上级召唤的候选祭品组。
	local mg=Duel.GetMatchingGroup(c28348537.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断这张卡等级是否≥7、本次召唤所需解放数是否≤1，以及候选祭品组中能否凑齐1只解放（即满足解放1只怪兽的上级召唤条件）。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行召唤规则效果的实际操作：重新获取候选祭品组，选择1只魔法师族怪兽作为解放素材，将其设定为这张卡的素材并解放，以完成上级召唤。
function c28348537.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 在解除操作中重新取得双方场上可作为解放素材的魔法师族怪兽。
	local mg=Duel.GetMatchingGroup(c28348537.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从候选祭品组中选择1只怪兽作为本次上级召唤的解放素材。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品怪兽解放，解放原因标记为召唤素材（REASON_SUMMON+REASON_MATERIAL）。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 这张卡通常召唤成功时触发：为当前玩家（雪暴公主控制者）注册一个持续到结束阶段、对象为对方的“不能发动魔法·陷阱卡”的场地效果。
function c28348537.actlimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡召唤成功的回合，对方不能把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c28348537.elimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果e1注册到决斗环境，直到结束阶段重置，从而在剩余回合内限制对方发动魔法·陷阱卡。
	Duel.RegisterEffect(e1,tp)
end
-- 这是EFFECT_CANNOT_ACTIVATE的判定函数：当对方发动的效果是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）时返回true，禁止该发动。
function c28348537.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
