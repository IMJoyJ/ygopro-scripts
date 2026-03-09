--聖剣 EX－カリバーン
-- 效果：
-- 「圣骑士」怪兽才能装备。「圣剑 断钢湖中剑」的②的效果1回合只能使用1次。
-- ①：装备怪兽不会成为对方的效果的对象。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「圣骑士」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「圣骑士」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c46008667.initial_effect(c)
	-- ①：装备怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46008667.target)
	e1:SetOperation(c46008667.operation)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「圣骑士」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「圣骑士」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46008667,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,46008667)
	-- 设置效果条件：这张卡送去墓地的回合不能发动这个效果
	e2:SetCondition(aux.exccon)
	-- 设置效果费用：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c46008667.sptg)
	e2:SetOperation(c46008667.spop)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果值：装备怪兽不会成为对方的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 「圣骑士」怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c46008667.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备对象必须是「圣骑士」怪兽
function c46008667.eqlimit(e,c)
	return c:IsSetCard(0x107a)
end
-- 过滤函数：检查是否为表侧表示的「圣骑士」怪兽
function c46008667.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- 效果处理：选择装备对象
function c46008667.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46008667.filter(chkc) end
	-- 判断是否满足装备条件：场上存在「圣骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c46008667.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象
	Duel.SelectTarget(tp,c46008667.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：装备卡牌
function c46008667.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 过滤函数：检查是否为表侧表示的「圣骑士」超量怪兽
function c46008667.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x107a)
		-- 判断是否满足特殊召唤条件：额外卡组存在不同卡名的「圣骑士」超量怪兽
		and Duel.IsExistingMatchingCard(c46008667.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
		-- 判断是否满足特殊召唤条件：目标怪兽必须能作为超量素材
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数：检查是否为「圣骑士」超量怪兽且满足特殊召唤条件
function c46008667.filter2(c,e,tp,mc,code)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x107a) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 判断是否满足特殊召唤条件：场上存在足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果处理：选择特殊召唤对象
function c46008667.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c46008667.filter1(chkc,e,tp) end
	-- 判断是否满足特殊召唤条件：场上存在符合条件的「圣骑士」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c46008667.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择特殊召唤对象
	Duel.SelectTarget(tp,c46008667.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：特殊召唤怪兽
function c46008667.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c46008667.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到召唤怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到召唤怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将召唤怪兽从额外卡组特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
