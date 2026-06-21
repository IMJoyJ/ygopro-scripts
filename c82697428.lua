--V・HERO ウィッチ・レイド
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的陷阱卡解放。
-- ①：这张卡召唤成功时才能发动。对方场上的魔法·陷阱卡全部破坏。这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤。
function c82697428.initial_effect(c)
	-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 设置代替解放的卡片类型为陷阱卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TRAP))
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。对方场上的魔法·陷阱卡全部破坏。这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82697428,1))  --"对方场上的魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCost(c82697428.descost)
	e2:SetTarget(c82697428.destg)
	e2:SetOperation(c82697428.desop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于检测本回合是否特殊召唤过非「英雄」怪兽
	Duel.AddCustomActivityCounter(82697428,ACTIVITY_SPSUMMON,c82697428.counterfilter)
end
-- 过滤函数：判断卡片是否属于「英雄」系列
function c82697428.counterfilter(c)
	return c:IsSetCard(0x8) and c:IsFaceup()
end
-- 效果①的发动代价函数：检查并注册本回合不能特殊召唤非「英雄」怪兽的限制
function c82697428.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查本回合是否未进行过非「英雄」怪兽的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(82697428,tp,ACTIVITY_SPSUMMON)==0 end
	-- 对方场上的魔法·陷阱卡全部破坏。这个效果发动的回合，自己不是「英雄」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c82697428.splimit)
	-- 向玩家注册不能特殊召唤非「英雄」怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤函数：限制非「英雄」怪兽的特殊召唤
function c82697428.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8)
end
-- 过滤函数：判断卡片是否为魔法或陷阱卡
function c82697428.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动检测与效果目标函数：确认对方场上存在魔法·陷阱卡并设置破坏的操作信息
function c82697428.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82697428.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c82697428.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息：破坏对方场上的所有魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理函数：破坏对方场上的所有魔法·陷阱卡
function c82697428.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c82697428.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 因效果破坏获取到的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
