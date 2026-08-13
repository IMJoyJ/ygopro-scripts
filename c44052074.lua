--古代の機械射出機
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有怪兽存在的场合，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，从卡组把1只「古代的机械」怪兽无视召唤条件特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，在自己场上把1只「古代的齿车衍生物」（机械族·地·1星·攻/守0）特殊召唤。
function c44052074.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上没有怪兽存在的场合，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，从卡组把1只「古代的机械」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44052074,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44052074)
	e1:SetCondition(c44052074.spcon)
	e1:SetTarget(c44052074.sptg)
	e1:SetOperation(c44052074.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己场上1张表侧表示卡为对象才能发动。那张卡破坏，在自己场上把1只「古代的齿车衍生物」（机械族·地·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44052074,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,44052074)
	-- 为②效果设置发动代价：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44052074.tktg)
	e2:SetOperation(c44052074.tkop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：自己场上没有怪兽存在时才能发动。
function c44052074.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上怪兽区的怪兽数量是否为0，以此判断“自己场上没有怪兽存在”。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义①效果从卡组选择特殊召唤对象的筛选条件：必须是「古代的机械」怪兽（0x7）、是怪兽卡，且能被效果无视召唤条件特殊召唤。
function c44052074.spfilter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 定义①效果的发动时目标选择与合法性检查：需选择自己场上1张表侧表示卡（不能选本卡）为对象，并确认怪兽区有空位且卡组有可特殊召唤的「古代的机械」怪兽。
function c44052074.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 进行合法性检查时，先确认自己场上怪兽区有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己场上存在1张表侧表示卡（除本卡外）可作为对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 并确认卡组中存在至少1只满足条件的「古代的机械」怪兽可被特殊召唤。
		and Duel.IsExistingMatchingCard(c44052074.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向玩家显示选择提示：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上表侧表示卡中选择1张（不能选本卡）作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 登记操作信息：本次效果将破坏选中的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本次效果将从卡组特殊召唤1只怪兽（对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果的解决处理：先破坏对象卡；若破坏成功且怪兽区有空位，则从卡组选择1只「古代的机械」怪兽无视召唤条件特殊召唤。
function c44052074.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，并因效果将其破坏；若破坏成功则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 若自己场上怪兽区空位不足，则无法特殊召唤，终止处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家显示选择提示：“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足条件的「古代的机械」怪兽。
		local g=Duel.SelectMatchingCard(tp,c44052074.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选怪兽无视召唤条件、以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 定义②效果的发动目标选择与合法性检查：根据自己怪兽区剩余空格动态选择对象范围，选自己场上1张表侧表示卡为对象，并确认能够特殊召唤「古代的齿车衍生物」。
function c44052074.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then
		-- 获取自己场上怪兽区的可用空格数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 确认指定位置存在1张表侧表示卡可作为破坏对象。
		return Duel.IsExistingTarget(Card.IsFaceup,tp,loc,0,1,nil)
			-- 同时确认当前玩家能够特殊召唤「古代的齿车衍生物」（机械族·地·1星·攻/守0）。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH)
	end
	-- 向玩家显示选择提示：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上指定范围内选择1张表侧表示卡作为对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,e:GetLabel(),0,1,1,nil)
	-- 登记操作信息：本次效果将破坏选中的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本次效果将特殊召唤衍生物（token）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记操作信息：本次效果包含特殊召唤动作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义②效果的解决处理：先破坏对象卡；若破坏成功且满足特殊召唤衍生物的条件，则在自己场上特殊召唤1只「古代的齿车衍生物」。
function c44052074.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，并因效果将其破坏；若破坏成功则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查自己场上怪兽区是否有空位，若没有则无法特殊召唤衍生物。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 或无法特殊召唤「古代的齿车衍生物」时，终止处理。
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,44052075,0x7,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
		-- 创建1只「古代的齿车衍生物」衍生物（token，卡号44052075）。
		local token=Duel.CreateToken(tp,44052075)
		-- 将衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
