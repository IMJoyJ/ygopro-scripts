--発条の巻き上げ
-- 效果：
-- 这张卡的①②的效果在同一连锁上不能发动。
-- ①：1回合1次，以自己场上1只机械族超量怪兽为对象才能发动。选自己的手卡·场上1只「发条」怪兽在作为对象的怪兽下面重叠作为超量素材。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己场上1只「发条」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「发条」超量怪兽在那上面重叠当作超量召唤从额外卡组特殊召唤。
function c83319610.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只机械族超量怪兽为对象才能发动。选自己的手卡·场上1只「发条」怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83319610,0))  --"把「发条」怪兽作为超量素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c83319610.mttg)
	e2:SetOperation(c83319610.mtop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己场上1只「发条」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「发条」超量怪兽在那上面重叠当作超量召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83319610,1))  --"把高1阶的「发条」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCost(c83319610.spcost)
	e3:SetTarget(c83319610.sptg)
	e3:SetOperation(c83319610.spop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的机械族超量怪兽，且手卡·场上存在可以作为其超量素材的「发条」怪兽
function c83319610.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
		-- 检查手卡·场上是否存在至少1张可以作为超量素材的「发条」怪兽（排除自身）
		and Duel.IsExistingMatchingCard(c83319610.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
end
-- 过滤手卡（或场上表侧表示）的、可以作为超量素材的「发条」怪兽
function c83319610.filter2(c,e)
	return c:IsSetCard(0x58) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果①的发动准备：选择自己场上1只机械族超量怪兽作为对象
function c83319610.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c83319610.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在满足条件的机械族超量怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c83319610.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的机械族超量怪兽作为效果对象
	Duel.SelectTarget(tp,c83319610.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
-- 效果①的效果处理：将选定的「发条」怪兽作为超量素材叠放在对象怪兽下面
function c83319610.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家选择自己手卡·场上1只满足条件的「发条」怪兽
	local g=Duel.SelectMatchingCard(tp,c83319610.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,tc,e)
	if g:GetCount()>0 then
		local mg=g:GetFirst():GetOverlayGroup()
		if mg:GetCount()>0 then
			-- 根据规则，将作为素材的怪兽原本持有的超量素材送去墓地
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		-- 将选定的「发条」怪兽重叠在对象怪兽下面作为超量素材
		Duel.Overlay(tc,g)
	end
end
-- 过滤自己场上表侧表示的「发条」超量怪兽，且额外卡组存在比其高1阶的「发条」超量怪兽，并满足超量素材限制
function c83319610.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在比该怪兽阶级高1阶的、可以特殊召唤的「发条」超量怪兽
		and Duel.IsExistingMatchingCard(c83319610.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
		-- 检查该怪兽是否满足必须作为超量素材的规则限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中满足阶级、卡名要求，且能以场上怪兽为素材进行超量召唤的「发条」超量怪兽
function c83319610.spfilter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0x58) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，且额外怪兽区域有可用空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动代价：将魔法与陷阱区域表侧表示的这张卡送去墓地
function c83319610.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为发动代价的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备：检查同一连锁上未发动过此卡效果，并选择自己场上1只「发条」超量怪兽作为对象
function c83319610.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c83319610.spfilter1(chkc,e,tp) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否存在满足条件的「发条」超量怪兽作为效果对象
		and Duel.IsExistingTarget(c83319610.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「发条」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c83319610.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：将高1阶的「发条」超量怪兽重叠在对象怪兽上面当作超量召唤特殊召唤，并继承素材
function c83319610.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否满足必须作为超量素材的规则限制，若不满足则结束处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只比对象怪兽高1阶的「发条」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c83319610.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽持有的超量素材转移到新召唤的超量怪兽下面
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽重叠在新召唤的超量怪兽下面作为超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新召唤的「发条」超量怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
