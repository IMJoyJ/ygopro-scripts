--捕食植物デェアデビル
-- 效果：
-- 「捕食植物」怪兽＋1星怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只「捕食植物」怪兽和自己或对方的场上1只有捕食指示物放置的怪兽解放的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的自己·对方回合的主要阶段，以最多有着有捕食指示物放置的怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册召唤限制、特殊召唤手续以及破坏魔法·陷阱卡的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「捕食植物」怪兽和1星怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),aux.FilterBoolFunction(Card.IsLevel,1),true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 设定特殊召唤条件限制为融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把自己场上1只「捕食植物」怪兽和自己或对方的场上1只有捕食指示物放置的怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的自己·对方回合的主要阶段，以最多有着有捕食指示物放置的怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤融合素材1（自己场上的「捕食植物」怪兽且可作为融合素材，且其余卡中存在符合条件的被放置捕食指示物的怪兽）
function s.hspfilter1(c,tp,fc,g)
	return c:IsFusionSetCard(0x10f3)
		and c:IsControler(tp) and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		and g:IsExists(s.hspfilter2,1,c,tp,fc)
end
-- 过滤融合素材2（表侧表示且被放置捕食指示物的怪兽，且可作为融合素材被解放）
function s.hspfilter2(c,tp,fc)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
		and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 过滤符合解放手续的怪兽（「捕食植物」怪兽或有捕食指示物放置的怪兽，可作为融合素材解放）
function s.hspfilter(c,tp,fc)
	return (c:IsFaceup() or c:IsControler(tp)) and (c:IsFusionSetCard(0x10f3) or c:GetCounter(0x1041)>0)
		and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 过滤出满足特殊召唤条件的解放卡片组合，并确认额外怪兽区域有空位
function s.fselect(g,tp,fc)
	-- 检查是否存在符合解放条件的怪兽组合，并确认从额外卡组特殊召唤的可用区域充足
	return g:IsExists(s.hspfilter1,1,nil,tp,fc,g) and Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
end
-- 定义自身方法特殊召唤的条件检查函数
function s.hspcon(e,c)
	if c==nil then return true end
	-- 获取双方场上所有可以作为特殊召唤解放手续素材的怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandlerPlayer(),c)
	return rg:CheckSubGroup(s.fselect,2,2,e:GetHandlerPlayer(),c)
end
-- 定义自身方法特殊召唤的目标选择与缓存函数
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取双方场上符合解放条件的怪兽卡组
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg and sg:GetCount()>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义自身方法特殊召唤的执行函数
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选择的素材怪兽解放以进行特殊召唤
	Duel.Release(sg,REASON_SPSUMMON|REASON_MATERIAL)
	sg:DeleteGroup()
end
-- 定义破坏魔法·陷阱卡效果的发动条件函数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认此卡在特殊召唤的回合且当前是主要阶段
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsMainPhase()
end
-- 过滤表侧表示且放置有捕食指示物的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 过滤魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义破坏效果的靶点选择与操作信息注册函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算场上表侧表示放置有捕食指示物的怪兽数量作为破坏目标的数量上限
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 确认效果发动时场上存在符合条件的破坏对象且存在有捕食指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等同于场上有捕食指示物怪兽数量的场上的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理的操作信息为破坏所选的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义破坏效果的执行操作函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动阶段被选择的成为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToChain,nil):Filter(Card.IsOnField,nil)
	-- 将场上依然与连锁关系相符的被选择卡片破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
