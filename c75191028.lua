--GMX - COMPREX
-- 效果：
-- 「GMX」怪兽+恐龙族怪兽2只以上
-- 根据作为这张卡融合素材的恐龙族怪兽数量得到以下效果。
-- ●3只以上：对方不能把这张卡作为效果的对象。
-- ●4只以上：在同1次的战斗阶段中可以作3次攻击。
-- ●5只以上：每次对方把怪兽召唤·特殊召唤，对方失去800基本分。
-- 1回合1次，自己用「GMX」卡的效果翻卡的场合：可以把场上的其他怪兽全部破坏。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制、添加融合召唤手续、注册融合素材检查效果、特召成功时的素材数量判断与效果赋予、以及我方翻卡成功时破坏场上其它怪兽的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 「GMX」怪兽+恐龙族怪兽2只以上
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1dd),aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),2,127,true)
	-- 根据作为这张卡融合素材的恐龙族怪兽数量得到以下效果。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- 根据作为这张卡融合素材的恐龙族怪兽数量得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- 1回合1次，自己用「GMX」卡的效果翻卡的场合：可以把场上的其他怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+1595137)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 融合素材检查：统计融合素材中恐龙族怪兽的数量，并将数量保存在标签值中
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsRace,nil,RACE_DINOSAUR)
	e:SetLabel(#mg1)
end
-- 判断是否是通过融合召唤的方式进行特殊召唤
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 根据融合召唤成功时使用的恐龙族怪兽素材数量，赋予对应的永续/诱发效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if ct==0 then return end
	if ct>=3 then
		-- ●3只以上：对方不能把这张卡作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置不能成为效果对象效果的阻抗类型：不受对手的卡片效果选择为对象
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"3只以上恐龙族怪兽作为融合素材"
	end
	if ct>=4 then
		-- ●4只以上：在同1次的战斗阶段中可以作3次攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"4只以上恐龙族怪兽作为融合素材"
	end
	if ct>=5 then
		-- ●5只以上：每次对方把怪兽召唤·特殊召唤，对方失去800基本分。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SUMMON_SUCCESS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCondition(s.reccon)
		e3:SetOperation(s.recop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e4)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"5只以上恐龙族怪兽作为融合素材"
	end
end
-- 过滤条件：是由对方召唤/特殊召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断对方召唤/特殊召唤成功的怪兽中是否存在至少1只怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 当对方召唤/特殊召唤成功时的扣除基本分处理
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示此卡发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 对方失去800基本分。
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)-800)
end
-- 判断引发自订事件（我方用「GMX」卡的效果翻卡）的玩家是否是自己
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
-- 破坏效果的发动合法性检查与破坏操作信息注册
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可行性检查：场上是否存在除了此卡以外的其它怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除了此卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置破坏操作信息：破坏场上除了此卡以外的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理逻辑
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除此卡（如果在场）以外的所有其它怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 破坏选择的所有怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
