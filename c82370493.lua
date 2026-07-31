--捕食植物デェアデビル
-- 效果：
-- 「捕食植物」怪兽＋1星怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只「捕食植物」怪兽和自己或对方的场上1只有捕食指示物放置的怪兽解放的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的自己·对方回合的主要阶段，以最多有着有捕食指示物放置的怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续与限制、①解放捕食植物与带捕食指示物怪兽特召手续、②特召回合主阶段破坏魔法·陷阱卡效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：「捕食植物」怪兽＋1星怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),aux.FilterBoolFunction(Card.IsLevel,1),true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 限制此卡只能通过融合召唤或自身规定的特殊召唤手续特召
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
s.mentioned_counter={
	[0x1041]=true,
}
-- 特召素材1过滤条件：自己场上的「捕食植物」怪兽
function s.hspfilter1(c,tp,fc,g)
	return c:IsFusionSetCard(0x10f3)
		and c:IsControler(tp) and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		and g:IsExists(s.hspfilter2,1,c,tp,fc)
end
-- 特召素材2过滤条件：双方场上有捕食指示物放置的表侧表示怪兽
function s.hspfilter2(c,tp,fc)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
		and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 特召素材综合过滤条件：可作为融合素材解放的怪兽
function s.hspfilter(c,tp,fc)
	return (c:IsFaceup() or c:IsControler(tp)) and (c:IsFusionSetCard(0x10f3) or c:GetCounter(0x1041)>0)
		and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 特召素材组合检查：必须包含1只己方捕食植物和1只带捕食指示物怪兽，且腾出额外卡组特召空位
function s.fselect(g,tp,fc)
	-- 检查选中的素材组合是否合法且满足额外卡组特召空位
	return g:IsExists(s.hspfilter1,1,nil,tp,fc,g) and Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
end
-- 特殊召唤手续条件：双方场上存在可解放的对应素材
function s.hspcon(e,c)
	if c==nil then return true end
	-- 获取双方场上所有符合条件的特召素材怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandlerPlayer(),c)
	return rg:CheckSubGroup(s.fselect,2,2,e:GetHandlerPlayer(),c)
end
-- 特殊召唤手续准备：选择2只符合条件的怪兽作为解放素材
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取双方场上可作为特召素材的怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	-- 提示玩家选择要解放的素材怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg and sg:GetCount()>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续处理：解放选中的素材怪兽特殊召唤自身
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选中的2只怪兽解放
	Duel.Release(sg,REASON_SPSUMMON|REASON_MATERIAL)
	sg:DeleteGroup()
end
-- ①效果发动条件：此卡特殊召唤的回合且处于双方的主要阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否在本回合特殊召唤且当前为主要阶段
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsMainPhase()
end
-- 指示物计数过滤条件：场上有捕食指示物放置的表侧表示怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 破坏目标过滤条件：场上的魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果发动准备：根据带捕食指示物怪兽数量选择最多等量的魔陷卡为对象并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计双方场上有捕食指示物放置的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 发动条件检查：场上是否存在魔陷卡且至少有1只带捕食指示物怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等于捕食指示物怪兽数量的魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁操作信息：破坏选中的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：破坏目标魔法·陷阱卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁设定的目标卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToChain,nil):Filter(Card.IsOnField,nil)
	-- 将目标魔法·陷阱卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
