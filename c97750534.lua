--死の代行者 ウラヌス
-- 效果：
-- ①：场上有「天空的圣域」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「代行者」怪兽送去墓地。这张卡的等级变成和那只怪兽的等级相同。
function c97750534.initial_effect(c)
	-- 将「天空的圣域」的卡片密码注册到本卡的关联卡片列表中。
	aux.AddCodeList(c,56433456)
	-- ①：场上有「天空的圣域」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c97750534.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「代行者」怪兽送去墓地。这张卡的等级变成和那只怪兽的等级相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97750534,0))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c97750534.tgtg)
	e2:SetOperation(c97750534.tgop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤规则的条件判断函数。
function c97750534.spcon(e,c)
	-- 在不进行怪兽区域检查时，仅判断场上是否存在「天空的圣域」。
	if c==nil then return Duel.IsEnvironment(56433456) end
	-- 判断当前玩家的怪兽区域是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤卡组中属于「代行者」系列且可以送去墓地的怪兽卡。
function c97750534.filter(c)
	return c:IsSetCard(0x44) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义效果②的发动检测与效果分类注册函数。
function c97750534.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只满足条件的「代行者」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c97750534.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表明此效果会将卡组的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的实际处理函数。
function c97750534.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在客户端显示“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的「代行者」怪兽。
	local g=Duel.SelectMatchingCard(tp,c97750534.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽因效果送去墓地，并确认其已成功送入墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=tc:GetLevel()
		-- 这张卡的等级变成和那只怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
