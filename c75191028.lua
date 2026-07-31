--GMX－COMPREX
-- 效果：
-- 「GMX」怪兽+恐龙族怪兽2只以上
-- 根据作为这张卡融合素材的恐龙族怪兽数量得到以下效果。
-- ●3只以上：对方不能把这张卡作为效果的对象。
-- ●4只以上：在同1次的战斗阶段中可以作3次攻击。
-- ●5只以上：每次对方把怪兽召唤·特殊召唤，对方失去800基本分。
-- 1回合1次，自己用「GMX」卡的效果翻卡的场合：可以把场上的其他怪兽全部破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续、素材检测及各条件获得的效果与翻卡破坏效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：1只「GMX」怪兽＋恐龙族怪兽2只以上
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1dd),aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),2,127,true)
	-- 初始化卡片效果：注册融合素材恐龙族怪兽数量检查效果
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- 初始化卡片效果：注册融合召唤成功时根据恐龙族素材数量赋予额外效果的状态注册器
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- 初始化卡片效果：注册「GMX」翻卡成功时破坏场上其他怪兽的诱发效果
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
-- 融合素材检查处理：统计作为融合素材的恐龙族怪兽数量并记录到Label
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsRace,nil,RACE_DINOSAUR)
	e:SetLabel(#mg1)
end
-- 素材效果赋予条件检查：此卡必须是融合召唤成功
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 根据恐龙族素材数量赋予对应永续/诱发效果：≥3得到对象抗性，≥4得到3次攻击，≥5得到对方召·特召扣血
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if ct==0 then return end
	if ct>=3 then
		-- 动态注册效果：3只以上恐龙族素材时赋予的对象选择抗性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置抗性判定：不能成为对方效果的对象
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"3只以上恐龙族怪兽作为融合素材"
	end
	if ct>=4 then
		-- 动态注册效果：4只以上恐龙族素材时赋予的最多3次攻击权限
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
		-- 动态注册效果：5只以上恐龙族素材时对方召唤·特召扣血800的效果
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
-- 怪兽召唤/特召玩家过滤：检查是否由指定玩家进行召唤
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 扣血效果发动条件：对方成功召唤或特殊召唤了怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 扣血效果处理：对方失去800基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动/效果触发提示
	Duel.Hint(HINT_CARD,0,id)
	-- 减少对方基本分800点
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)-800)
end
-- 破坏效果发动条件：翻卡效果的发动玩家为自己
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
-- 破坏效果发动准备：设置破坏场上除自身外所有怪兽的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：场上是否存在除自身外的其他怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除自身外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理：破坏场上除自身外的所有怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除此卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将匹配的怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
