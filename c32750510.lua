--アイス・ブリザード・マスター
-- 效果：
-- 这张卡可以把自己场上2只水属性怪兽解放，从手卡特殊召唤。1回合1次，可以选择场上表侧表示存在的1只怪兽放置1个冰指示物。此外，可以通过把这张卡解放，有冰指示物放置的怪兽全部破坏。
function c32750510.initial_effect(c)
	-- 这张卡可以把自己场上2只水属性怪兽解放，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32750510.spcon)
	e1:SetTarget(c32750510.sptg)
	e1:SetOperation(c32750510.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以选择场上表侧表示存在的1只怪兽放置1个冰指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32750510,0))  --"放置「冰指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c32750510.target)
	e2:SetOperation(c32750510.operation)
	c:RegisterEffect(e2)
	-- 此外，可以通过把这张卡解放，有冰指示物放置的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32750510,1))  --"放置有「冰指示物」的怪兽全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c32750510.descost)
	e3:SetTarget(c32750510.destg)
	e3:SetOperation(c32750510.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的水属性怪兽（包括自己控制的或表侧表示的）
function c32750510.rfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足特殊召唤条件：手卡中的这张卡能否通过解放2只水属性怪兽进行特殊召唤
function c32750510.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的怪兽组，并筛选出水属性的怪兽
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c32750510.rfilter,nil,tp)
	-- 检查所选的水属性怪兽组是否满足特殊召唤所需的主怪兽区空位条件
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 设置特殊召唤时的选择目标，选择2只符合条件的水属性怪兽进行解放
function c32750510.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组，并筛选出水属性的怪兽
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c32750510.rfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从符合条件的怪兽中选择2只并验证其是否满足特殊召唤的区域要求
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作，将选中的怪兽解放
function c32750510.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际执行解放操作
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置放置冰指示物的效果目标，选择一个可以放置冰指示物的怪兽
function c32750510.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1015,1) end
	-- 检查是否存在可以放置冰指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1015,1) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个可以放置冰指示物的怪兽
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1015,1)
	-- 设置操作信息，表明本次效果将放置冰指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 执行放置冰指示物的操作
function c32750510.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1015,1) then
		tc:AddCounter(0x1015,1)
	end
end
-- 设置破坏效果的解放费用，需要将自身解放
function c32750510.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际执行将自身解放的操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选拥有冰指示物的怪兽
function c32750510.desfilter(c)
	return c:GetCounter(0x1015)~=0
end
-- 设置破坏效果的目标，选择所有拥有冰指示物的怪兽
function c32750510.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在拥有冰指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32750510.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取所有拥有冰指示物的怪兽组
	local g=Duel.GetMatchingGroup(c32750510.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息，表明本次效果将破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将所有拥有冰指示物的怪兽破坏
function c32750510.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有拥有冰指示物的怪兽组（排除自身）
	local g=Duel.GetMatchingGroup(c32750510.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 实际执行破坏操作
	Duel.Destroy(g,REASON_EFFECT)
end
