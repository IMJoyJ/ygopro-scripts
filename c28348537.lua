--ブリザード・プリンセス
-- 效果：
-- 这张卡可以把1只魔法师族怪兽解放表侧攻击表示上级召唤。这张卡召唤成功的回合，对方不能把魔法·陷阱卡发动。
function c28348537.initial_effect(c)
	-- 这张卡可以把1只魔法师族怪兽解放表侧攻击表示上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28348537,0))  --"把1只魔法师族怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c28348537.otcon)
	e1:SetOperation(c28348537.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功的回合，对方不能把魔法·陷阱卡发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c28348537.actlimit)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的魔法师族怪兽
function c28348537.otfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤的条件
function c28348537.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的怪兽组作为祭品候选
	local mg=Duel.GetMatchingGroup(c28348537.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查是否存在满足条件的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤的解放操作
function c28348537.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足条件的怪兽组作为祭品候选
	local mg=Duel.GetMatchingGroup(c28348537.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 设置对方不能发动魔法·陷阱卡的效果
function c28348537.actlimit(e,tp,eg,ep,ev,re,r,rp)
	-- 注册对方不能发动魔法·陷阱卡的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c28348537.elimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能无效魔法·陷阱卡的发动
function c28348537.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
