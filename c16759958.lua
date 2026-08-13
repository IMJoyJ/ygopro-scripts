--アロマセラフィ－アンゼリカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己墓地1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
-- ②：这张卡在墓地存在，自己基本分比对方多，自己场上有「芳香」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c16759958.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方回合，把这张卡从手卡丢弃，以自己墓地1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16759958,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,16759958)
	e1:SetCost(c16759958.reccost)
	e1:SetTarget(c16759958.rectg)
	e1:SetOperation(c16759958.recop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己基本分比对方多，自己场上有「芳香」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16759958,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16759959)
	e2:SetCondition(c16759958.spcon)
	e2:SetTarget(c16759958.sptg)
	e2:SetOperation(c16759958.spop)
	c:RegisterEffect(e2)
end
-- 代价判定与执行：若这张卡可丢弃，则将其从手卡丢弃（REASON_COST+REASON_DISCARD）作为发动代价。
function c16759958.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将发动效果的这张卡自身从手卡送去墓地，作为①效果的代价丢弃。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 目标筛选条件：选择自己墓地1只「芳香」怪兽，且其攻击力大于0。
function c16759958.recfilter(c)
	return c:IsSetCard(0xc9) and c:GetAttack()>0
end
-- ①效果的目标选择与操作登记：从自己墓地选择1只攻击力＞0的「芳香」怪兽为对象，并登记回复其攻击力数值的LP。
function c16759958.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16759958.recfilter(chkc) end
	-- 发动条件判定：自己墓地是否存在至少1张符合条件的「芳香」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c16759958.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家正在选择效果的对象（HINTMSG_TARGET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1张满足条件的「芳香」怪兽，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c16759958.recfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本次连锁将执行回复LP的效果，预定回复数值为所选对象怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
-- 效果处理：取得对象怪兽，若对象仍与效果关联且攻击力＞0，则自己回复该攻击力数值的LP。
function c16759958.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所选择的对象卡（墓地那只「芳香」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 以效果原因让自己回复tc当前攻击力数值的LP。
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 过滤器：判断一张卡是否为表侧表示且属于「芳香」字段。
function c16759958.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- ②效果发动条件：自己LP高于对方LP，并且自己场上有表侧表示的「芳香」怪兽存在。
function c16759958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查：自己LP大于对方LP，且自己主要怪兽区存在至少1张表侧表示「芳香」怪兽。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp) and Duel.IsExistingMatchingCard(c16759958.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动目标/条件判定：主要怪兽区有空位，且此卡在墓地可以被特殊召唤，满足则可发动。
function c16759958.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次处理将特殊召唤此卡自身（类别：特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍在墓地且与效果关联有效，则以表侧攻击表示特殊召唤；成功后给它附加『从场上离开的场合除外』的离场代替效果。
function c16759958.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联后将其特殊召唤；若特殊召唤成功，则继续为其附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
