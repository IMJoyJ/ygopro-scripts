--Imposter Shift
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：对方把以自己场上的怪兽为对象的场上的怪兽的效果发动时才能适用。对方可以从自己墓地把1张卡除外。没有除外的场合，那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：从自己墓地把1只等级1以上的怪兽除外才能发动。在自己场上把1只持有和除外的怪兽相同等级的衍生物特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.tokencost)
	e3:SetTarget(s.tokentg)
	e3:SetOperation(s.tokenop)
	c:RegisterEffect(e3)
end
-- 检查目标卡是否还在场上，且不与发动效果的卡在同一纵列
function s.tfilter(c,rc,ev)
	return c:IsOnField() and c:IsRelateToChain(ev) and not rc:GetColumnGroup():IsContains(c)
end
-- 无效效果的触发条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取效果的对象卡组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local rc=re:GetHandler()
	-- 判断是否是对方在怪兽区域发动的怪兽效果，且连锁可以被无效
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
		and rc:IsRelateToChain(ev) and rc:IsControler(rp) and rc:IsType(TYPE_MONSTER)
		and tg and tg:IsExists(s.tfilter,1,rc,rc,ev)
end
-- 无效效果的处理
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local res=false
	-- 判断对方墓地是否有能除外的卡并询问对方是否除外
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil,1-tp) and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		-- 提示对方选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让对方从其墓地选择1张要除外的卡
		local g=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,1,nil,tp)
		-- 判断对方是否成功除外了卡
		if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT,1-tp)>0 then
			res=true
		end
	end
	if not res then
		-- 展示本卡发动动画
		Duel.Hint(HINT_CARD,0,id)
		-- 使那个效果无效
		Duel.NegateEffect(ev)
	end
end
-- 检查是否是能作为代价除外的有等级的怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsLevelAbove(1) and c:IsFaceupEx()
		-- 检查能否特殊召唤对应等级的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,c:GetLevel(),RACE_PSYCHO,ATTRIBUTE_EARTH)
end
-- 特殊召唤衍生物的代价
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地是否有能作为代价的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c,tp) end
	-- 提示自己选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己从墓地选择1只怪兽作为代价
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c,tp):GetFirst()
	e:SetLabel(tc:GetLevel())
	-- 将选中的卡作为代价除外
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
-- 特殊召唤衍生物的目标设定
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有怪兽区域以及是否支付了代价
	if chk==0 then return e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置生成衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物的处理
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 判断自己场上是否有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断能否特殊召唤对应等级的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,lv,RACE_PSYCHO,ATTRIBUTE_EARTH) then
		-- 生成衍生物
		local tk=Duel.CreateToken(tp,id+o)
		-- 这只衍生物的等级变成和作为此卡发动代价除外的怪兽等级相同
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(lv)
		tk:RegisterEffect(e1,true)
		-- 将衍生物特殊召唤到自己场上
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
	end
end
