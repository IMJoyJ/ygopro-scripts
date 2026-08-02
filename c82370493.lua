--捕食植物デェアデビル
-- 效果：
-- 「捕食植物」怪兽＋1星怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只「捕食植物」怪兽和自己或对方的场上1只有捕食指示物放置的怪兽解放的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的自己·对方回合的主要阶段，以最多有着有捕食指示物放置的怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 声明initial_effect函数，添加融合召唤手续，注册限制特召方式和破坏场上魔陷等效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 「捕食植物」怪兽＋1星怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),aux.FilterBoolFunction(Card.IsLevel,1),true)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 设置特殊召唤方式限制，只能通过特定的召唤手续进行
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 把自己场上1只「捕食植物」怪兽和自己或对方的场上1只有捕食指示物放置的怪兽解放的场合可以特殊召唤。
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
-- 过滤条件：判断是否为自己场上可作为融合素材的「捕食植物」怪兽
function s.hspfilter1(c,tp,fc,g)
	return c:IsFusionSetCard(0x10f3)
		and c:IsControler(tp) and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		and g:IsExists(s.hspfilter2,1,c,tp,fc)
end
-- 过滤条件：判断是否为有捕食指示物且可解放、可作为素材的怪兽
function s.hspfilter2(c,tp,fc)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
		and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 过滤条件：判断是否为符合特殊召唤解放条件的候选怪兽
function s.hspfilter(c,tp,fc)
	return (c:IsFaceup() or c:IsControler(tp)) and (c:IsFusionSetCard(0x10f3) or c:GetCounter(0x1041)>0)
		and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 判断选择的2只怪兽是否满足解放组合以及额外怪兽区是否有空位
function s.fselect(g,tp,fc)
	-- 判断组合中是否包含自己场上的「捕食植物」怪兽并且有额外的特召空间
	return g:IsExists(s.hspfilter1,1,nil,tp,fc,g) and Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
end
-- 判断是否能够凑齐满足解放特殊召唤此卡的素材组合
function s.hspcon(e,c)
	if c==nil then return true end
	-- 获取场上所有符合解放条件的候选怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandlerPlayer(),c)
	return rg:CheckSubGroup(s.fselect,2,2,e:GetHandlerPlayer(),c)
end
-- 选择用于解放的素材怪兽并设为效果对象保存
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有可以作为特召解放素材的怪兽
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	-- 提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg and sg:GetCount()>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行解放选定的素材怪兽进行特殊召唤的操作
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 把自己场上1只「捕食植物」怪兽和自己或对方的场上1只有捕食指示物放置的怪兽解放
	Duel.Release(sg,REASON_SPSUMMON|REASON_MATERIAL)
	sg:DeleteGroup()
end
-- 判断是否在特殊召唤的回合的主要阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡特殊召唤的自己·对方回合的主要阶段
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsMainPhase()
end
-- 过滤条件：判断场上怪兽是否放置有捕食指示物
function s.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 过滤条件：判断卡片是否为魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断场上有捕食指示物怪兽及魔陷数量并设置破坏目标及操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算场上放置有捕食指示物的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 判断是否存在可破坏的魔法·陷阱卡且有捕食指示物怪兽存在
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以最多有着有捕食指示物放置的怪兽数量的场上的魔法·陷阱卡为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置破坏魔法·陷阱卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏对象魔法·陷阱卡的操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被指定为对象的魔法·陷阱卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToChain,nil):Filter(Card.IsOnField,nil)
	-- 那些卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
