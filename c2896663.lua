--ZW－弩級兵装竜王戟
-- 效果：
-- 5星怪兽×2
-- ①：这张卡不能直接攻击。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「异热同心」魔法·陷阱卡加入手卡。
-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升3000的装备卡使用给那只怪兽装备。
-- ④：装备怪兽战斗破坏怪兽时才能发动。选给装备怪兽装备的「异热同心武器」怪兽卡任意数量特殊召唤。
function c2896663.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为5、数量为2的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「异热同心」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2896663,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c2896663.thcost)
	e2:SetTarget(c2896663.thtg)
	e2:SetOperation(c2896663.thop)
	c:RegisterEffect(e2)
	-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升3000的装备卡使用给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2896663,1))  --"变成装备"
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c2896663.eqtg)
	e3:SetOperation(c2896663.eqop)
	c:RegisterEffect(e3)
	-- ④：装备怪兽战斗破坏怪兽时才能发动。选给装备怪兽装备的「异热同心武器」怪兽卡任意数量特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2896663,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c2896663.spcon)
	e4:SetTarget(c2896663.sptg)
	e4:SetOperation(c2896663.spop)
	c:RegisterEffect(e4)
end
-- 支付效果代价：移除1个超量素材
function c2896663.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤器：卡图属于异热同心系列的魔法或陷阱卡且能加入手牌
function c2896663.thfilter(c)
	return c:IsSetCard(0x7e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理信息：准备从卡组检索1张「异热同心」魔法或陷阱卡
function c2896663.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2896663.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：准备从卡组检索1张「异热同心」魔法或陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并加入手牌
function c2896663.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c2896663.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 装备目标过滤器：己方场上表侧表示的「希望皇 霍普」怪兽
function c2896663.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 设置装备效果处理信息：选择目标怪兽
function c2896663.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2896663.eqfilter(chkc) end
	-- 判断是否满足装备条件：己方魔法陷阱区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备条件：己方场上存在满足条件的怪兽
		and Duel.IsExistingTarget(c2896663.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c2896663.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：准备进行装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备效果处理：装备给目标怪兽
function c2896663.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否失败：魔法陷阱区域无空位或目标怪兽不满足条件
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:GetControler()==1-tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c2896663.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作：装备给目标怪兽并设置装备效果
function c2896663.zw_equip_monster(c,tp,tc)
	-- 尝试装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果：只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c2896663.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备攻击力提升效果：提升3000攻击力
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(3000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判断函数：只能装备给设定的怪兽
function c2896663.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 战斗破坏时的触发条件：被装备的怪兽战斗破坏怪兽
function c2896663.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 特殊召唤过滤器：表侧表示的「异热同心武器」怪兽且能特殊召唤
function c2896663.spfilter(c,e,tp,eqg)
	return c:IsFaceup() and c:IsSetCard(0x107e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and eqg:IsContains(c)
end
-- 设置特殊召唤效果处理信息：准备特殊召唤「异热同心武器」怪兽
function c2896663.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local eqg=ec:GetEquipGroup()
	-- 判断是否满足特殊召唤条件：己方魔法陷阱区域有空位且装备怪兽参与战斗
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c2896663.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp,eqg) and ec:IsRelateToBattle() end
	-- 设置效果处理信息：准备特殊召唤「异热同心武器」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_SZONE)
end
-- 执行特殊召唤效果处理：选择并特殊召唤
function c2896663.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	-- 获取己方怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local eqg=ec:GetEquipGroup()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c2896663.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,ft,nil,e,tp,eqg)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
