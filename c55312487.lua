--クルセイド・パラディオン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡也能把自己场上1只「圣像骑士」怪兽或者「星遗物」怪兽解放来发动。那个场合，从自己的卡组·墓地选原本卡名和那只怪兽不同的1只「圣像骑士」怪兽或者「星遗物」怪兽特殊召唤。
-- ②：只要自己场上有「圣像骑士」连接怪兽存在，对方只能选择连接怪兽作为攻击对象。
function c55312487.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡也能把自己场上1只「圣像骑士」怪兽或者「星遗物」怪兽解放来发动。那个场合，从自己的卡组·墓地选原本卡名和那只怪兽不同的1只「圣像骑士」怪兽或者「星遗物」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,55312487+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c55312487.target)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「圣像骑士」连接怪兽存在，对方只能选择连接怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c55312487.atcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c55312487.atlimit)
	c:RegisterEffect(e3)
end
-- 过滤自己场上可解放的「圣像骑士」或「星遗物」怪兽，且该怪兽解放后有可特殊召唤的原本卡名不同的怪兽
function c55312487.spfilter1(c,e,tp)
	-- 检查该卡是否为「圣像骑士」或「星遗物」怪兽，且解放该卡后能腾出可用的怪兽区域
	return c:IsSetCard(0xfe,0x116) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己的卡组或墓地是否存在满足特殊召唤条件的、原本卡名与该怪兽不同的怪兽
		and Duel.IsExistingMatchingCard(c55312487.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤卡组或墓地中原本卡名与解放怪兽不同、且可以特殊召唤的「圣像骑士」或「星遗物」怪兽
function c55312487.spfilter2(c,e,tp,rc)
	return c:IsSetCard(0xfe,0x116) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(rc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，判断是否进行解放怪兽并特殊召唤的动作，并进行相应的Cost支付和操作信息注册
function c55312487.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己场上是否存在可以解放的、满足条件的「圣像骑士」或「星遗物」怪兽
	if Duel.CheckReleaseGroup(tp,c55312487.spfilter1,1,nil,e,tp)
		-- 询问玩家是否选择解放场上的怪兽来发动特殊召唤的效果
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(55312487,0)) then  --"是否解放怪兽并特殊召唤？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(c55312487.activate)
		-- 让玩家选择1只场上要解放的「圣像骑士」或「星遗物」怪兽
		local rg=Duel.SelectReleaseGroup(tp,c55312487.spfilter1,1,1,nil,e,tp)
		e:SetLabelObject(rg:GetFirst())
		-- 将选中的怪兽解放作为发动的代价
		Duel.Release(rg,REASON_COST)
		-- 设置效果处理的操作信息为：从卡组或墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- 效果处理函数，从卡组或墓地特殊召唤1只原本卡名与解放怪兽不同的「圣像骑士」或「星遗物」怪兽
function c55312487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local rc=e:GetLabelObject()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或墓地选择1只满足条件且不受「王家长眠之谷」影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55312487.spfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,rc)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「圣像骑士」连接怪兽
function c55312487.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x116) and c:IsType(TYPE_LINK)
end
-- 限制攻击效果的适用条件函数：自己场上存在「圣像骑士」连接怪兽
function c55312487.atcon(e)
	-- 检查自己场上是否存在表侧表示的「圣像骑士」连接怪兽
	return Duel.IsExistingMatchingCard(c55312487.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制攻击目标函数：使对方不能选择里侧表示怪兽或非连接怪兽作为攻击对象
function c55312487.atlimit(e,c)
	return c:IsFacedown() or not c:IsType(TYPE_LINK)
end
