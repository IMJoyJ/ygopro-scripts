--ホイール・シンクロン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ②：自己主要阶段才能发动。进行1只4星以下的怪兽的召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ③：把墓地的这张卡除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽的等级下降最多4星。
local s,id,o=GetID()
-- 初始化效果注册：注册效果①（当作非调整）、效果②（召唤4星以下怪兽并限制额外特召）、效果③（除外自身降低同调怪兽等级）。
function s.initial_effect(c)
	-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(s.tnval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。进行1只4星以下的怪兽的召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽的等级下降最多4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 设置效果③的发动代价为：将墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- 效果①的过滤条件：仅在作为自己场上的同调素材时，才能当作非调整使用。
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- 过滤条件：手牌或场上等级4以下且可以进行通常召唤的怪兽。
function s.filter(c)
	return c:IsLevelBelow(4) and c:IsSummonable(true,nil)
end
-- 效果②的发动准备：检查手牌或场上是否存在可以召唤的4星以下怪兽，并设置召唤的操作信息。
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在至少1只满足召唤条件的4星以下怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理中的操作信息为：进行1只怪兽的召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：让玩家选择并召唤1只4星以下怪兽，并适用“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制。
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家从手牌或场上选择1只满足条件的4星以下怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合的通常召唤次数限制，对选中的怪兽进行召唤。
		Duel.Summon(tp,tc,true,nil)
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。 / ③：把墓地的这张卡除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽的等级下降最多4星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特召非同调怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤非同调怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：自己场上表侧表示、等级在2星以上的同调怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(2)
end
-- 效果③的发动准备：选择自己场上1只表侧表示且等级在2星以上的同调怪兽作为对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在满足条件的同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只满足条件的同调怪兽作为效果对象。
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的效果处理：让玩家选择要下降的等级（最多4星，且不能降到0星以下），并使目标怪兽的等级下降该数值。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果③选中的同调怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local t={}
		for i=1,4 do
			if tc:GetLevel()-i>0 then table.insert(t,i) end
		end
		if #t==0 then return end
		-- 玩家宣言要下降的等级数值。
		local lv=Duel.AnnounceNumber(tp,table.unpack(t))
		-- 那只怪兽的等级下降最多4星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-lv)
		tc:RegisterEffect(e1)
	end
end
