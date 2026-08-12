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
c32750510.mentioned_counter={
	[0x1015]=true,
}
-- 过滤函数：筛选水属性怪兽，且为自己控制或表侧表示的卡（作为可解放的候选怪兽）。
function c32750510.rfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤的发动条件：检查场上可解放的水属性怪兽中，是否存在2只一组的组合，使其解放后主怪兽区仍有空位完成特殊召唤。
function c32750510.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得自己场上可用于特殊召唤的解放卡片组，并过滤出水属性怪兽（自己控制或表侧表示）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c32750510.rfilter,nil,tp)
	-- 检查可解放怪兽组中是否存在恰好2只的子组，解放它们后主怪兽区仍有足够空位且确实可被解放。
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤的目标处理：让玩家选择要解放的2只水属性怪兽，并将选中的组合记录到效果中以便处理阶段解放。
function c32750510.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上可用于特殊召唤的解放卡片组，并过滤出水属性怪兽（自己控制或表侧表示）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c32750510.rfilter,nil,tp)
	-- 向玩家发送「请选择要解放的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从可解放的水属性怪兽中选择2只，要求解放后主怪兽区仍有空位且这些怪兽确实可被解放。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的处理：取出之前选中的2只怪兽，以特殊召唤为由将它们解放，然后清理临时卡组。
function c32750510.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为由解放选中的2只怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 放置冰指示物效果的目标处理：选择场上1只可以放置冰指示物的表侧表示怪兽作为对象，并设置指示物操作信息。
function c32750510.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1015,1) end
	-- 发动条件检查：双方场上是否存在至少1只可以放置冰指示物的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1015,1) end
	-- 向玩家发送「请选择表侧表示的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择双方场上1只可以放置冰指示物的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1015,1)
	-- 设置连锁操作信息：本连锁将处理1个放置指示物的效果（指示物对象在发动时不确定，故目标卡为nil）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果处理：取得对象怪兽，若其仍与本效果关联且可以放置冰指示物，则在其上放置1个冰指示物。
function c32750510.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1015,1) then
		tc:AddCounter(0x1015,1)
	end
end
-- 破坏效果的代价：确认这张卡可以解放，然后把这张卡解放作为发动代价。
function c32750510.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选放置有冰指示物的怪兽。
function c32750510.desfilter(c)
	return c:GetCounter(0x1015)~=0
end
-- 破坏效果的目标处理：确认场上存在放置有冰指示物的怪兽，取得全部这些怪兽并设置破坏操作信息。
function c32750510.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：除这张卡外，双方场上是否存在至少1只放置有冰指示物的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32750510.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 取得双方场上所有放置有冰指示物的怪兽（这张卡除外）。
	local g=Duel.GetMatchingGroup(c32750510.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁操作信息：本连锁将破坏所有放置有冰指示物的怪兽，数量为这些怪兽的总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：取得双方场上所有放置有冰指示物的怪兽（本卡除外），将它们全部破坏。
function c32750510.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上所有放置有冰指示物的怪兽（与本效果关联的这张卡除外）。
	local g=Duel.GetMatchingGroup(c32750510.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 以效果为由将这些怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
