--巨竜の守護騎士
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值的一半。
-- ③：把自己场上1只怪兽和这张卡解放，以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c33460840.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只7·8星的龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33460840.eqtg)
	e1:SetOperation(c33460840.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：把自己场上1只怪兽和这张卡解放，以自己墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c33460840.spcost)
	e3:SetTarget(c33460840.sptg)
	e3:SetOperation(c33460840.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选7·8星的龙族怪兽且未被禁止的卡。
function c33460840.filter(c,ec)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and not c:IsForbidden()
end
-- 效果处理时的判断条件，检查是否有足够的魔法陷阱区域以及手牌或墓地是否存在满足条件的卡。
function c33460840.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前玩家的魔法陷阱区域是否还有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断当前玩家的手牌或墓地是否存在至少一张满足条件的卡。
		and Duel.IsExistingMatchingCard(c33460840.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
end
-- 装备效果的处理函数，负责选择并装备符合条件的卡，并设置攻击力和守备力提升效果。
function c33460840.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足装备条件，包括魔法陷阱区域是否为空、卡片是否正面表示且与效果相关。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手牌或墓地选择一张满足条件的卡作为装备卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33460840.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c)
	local tc=g:GetFirst()
	-- 尝试将选中的卡装备给当前卡片，若失败则返回。
	if not (tc and Duel.Equip(tp,tc,c)) then return end
	local atk=math.ceil(tc:GetTextAttack()/2)
	local def=math.ceil(tc:GetTextDefense()/2)
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	-- 设置装备限制效果，确保只有装备卡能装备给该卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c33460840.eqlimit)
	tc:RegisterEffect(e1)
	if atk>0 then
		-- 设置装备卡的攻击力提升效果，提升值为其攻击力的一半（向上取整）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
	if def>0 then
		-- 设置装备卡的守备力提升效果，提升值为其守备力的一半（向上取整）。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(def)
		tc:RegisterEffect(e3)
	end
end
-- 装备限制效果的判断函数，确保只有装备卡能装备给该卡。
function c33460840.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 筛选函数，用于判断墓地中的卡是否为7·8星的龙族且可特殊召唤。
function c33460840.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的费用处理函数，需要解放一张卡作为费用。
function c33460840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的费用条件，即当前卡可解放且场上存在可解放的卡。
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroup(tp,nil,1,c) end
	-- 选择场上一张可解放的卡。
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,c)
	rg:AddCard(c)
	-- 将选中的卡进行解放操作。
	Duel.Release(rg,REASON_COST)
end
-- 特殊召唤效果的目标选择函数，用于选择墓地中的目标卡。
function c33460840.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33460840.spfilter(chkc,e,tp) end
	-- 判断当前玩家的怪兽区域是否还有足够的空间。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		-- 判断当前玩家的墓地中是否存在至少一张满足条件的卡。
		and Duel.IsExistingTarget(c33460840.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择一张满足条件的卡作为特殊召唤的目标。
	local g=Duel.SelectTarget(tp,c33460840.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表明本次效果将特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理函数，将目标卡特殊召唤到场上。
function c33460840.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以特殊召唤方式放入场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
