--ZW－弩級兵装竜王戟
-- 效果：
-- 5星怪兽×2
-- ①：这张卡不能直接攻击。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「异热同心」魔法·陷阱卡加入手卡。
-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升3000的装备卡使用给那只怪兽装备。
-- ④：装备怪兽战斗破坏怪兽时才能发动。选给装备怪兽装备的「异热同心武器」怪兽卡任意数量特殊召唤。
function c2896663.initial_effect(c)
	-- 给这张卡添加XYZ召唤手续，用任意2只5星怪兽作为超量素材叠放召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「异热同心」魔法·陷阱卡加入手卡。
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
	-- 以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升3000的装备卡使用给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2896663,1))  --"变成装备"
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c2896663.eqtg)
	e3:SetOperation(c2896663.eqop)
	c:RegisterEffect(e3)
	-- 装备怪兽战斗破坏怪兽时才能发动。选给装备怪兽装备的「异热同心武器」怪兽卡任意数量特殊召唤。
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
-- 作为发动代价，检查并实际从这张卡上取除1个超量素材。
function c2896663.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤器：卡名含有「异热同心」字段的魔法·陷阱卡，且能够加入手卡。
function c2896663.thfilter(c)
	return c:IsSetCard(0x7e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的合法性检查和操作信息设定：确认卡组存在可检索的对象，并声明本效果将执行从卡组把卡加入手卡的处理。
function c2896663.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时的合法性检查，确认卡组中存在至少1张满足检索条件的「异热同心」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c2896663.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时将把1张卡从卡组加入手卡（目标卡不确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「异热同心」魔法·陷阱卡加入手卡，并让对方确认加入手卡的卡。
function c2896663.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的「异热同心」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c2896663.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（处理原因为效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 装备对象过滤器：选择自己场上表侧表示且卡名含有「希望皇」字段的怪兽。
function c2896663.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 效果发动时的合法性检查和取对象处理：确认自己魔陷区有空位且场上存在符合条件的「希望皇 霍普」怪兽，并选择那只怪兽为对象。
function c2896663.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2896663.eqfilter(chkc) end
	-- 若为发动时的合法性检查，确认自己的魔陷区有空位（用于放置装备卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时确认场上存在1只可以成为装备对象的表侧表示「希望皇 霍普」怪兽。
		and Duel.IsExistingTarget(c2896663.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只符合条件的「希望皇 霍普」怪兽作为效果对象。
	Duel.SelectTarget(tp,c2896663.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果处理时将把这张卡作为装备卡装备（对象为发动时选择的怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：确认这张卡与目标仍合法且魔陷区有空位，若成立则将这张卡装备给目标怪兽；否则这张卡送去墓地。
function c2896663.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取发动时选择为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件：魔陷区仍有空位、这张卡仍在自己场上、目标怪兽仍表侧表示且与效果相关；任一不满足则准备把这卡送去墓地。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:GetControler()==1-tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因为装备条件不满足，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c2896663.zw_equip_monster(c,tp,tc)
end
-- 装备处理：把这张卡作为装备卡装备给目标怪兽，并给它添加只能装备给该怪兽的限制和攻击力上升3000的效果。
function c2896663.zw_equip_monster(c,tp,tc)
	-- 执行装备操作；若装备失败（例如怪兽已离场或格子被占），则中止后续处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c2896663.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升3000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(3000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制函数：这张卡只能装备给在自己装备时记录的目标怪兽（e:GetLabelObject()）。
function c2896663.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果④的触发条件：战斗破坏事件中涉及的第一只怪兽为装备着这张卡的怪兽（eg:GetFirst()与装备怪兽相同）。
function c2896663.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 特殊召唤过滤器：选择装备怪兽的装备区中表侧表示且属于「异热同心武器」字段、满足特殊召唤条件的怪兽卡。
function c2896663.spfilter(c,e,tp,eqg)
	return c:IsFaceup() and c:IsSetCard(0x107e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and eqg:IsContains(c)
end
-- 效果发动时的合法性检查：确认自己主要怪兽区有空位、装备怪兽的装备区中存在可特殊召唤的「异热同心武器」怪兽，并且装备怪兽仍与战斗相关；同时设置本效果将进行特殊召唤的操作信息。
function c2896663.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local eqg=ec:GetEquipGroup()
	-- 当为发动时合法性检查，确认主要怪兽区有空位、有满足条件的「异热同心武器」怪兽可特殊召唤，且装备怪兽仍与战斗破坏事件相关。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c2896663.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp,eqg) and ec:IsRelateToBattle() end
	-- 设置操作信息：本效果处理时将把卡从魔法与陷阱区域特殊召唤（数量为1以上，具体数量不确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_SZONE)
end
-- 效果处理：取得可用的主要怪兽区数量，若存在「青眼精灵龙」效果则限制为1；在装备怪兽的装备区中选择任意数量符合条件的「异热同心武器」怪兽特殊召唤。
function c2896663.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	-- 获取自己主要怪兽区的可用空格数量，用于决定特殊召唤数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local eqg=ec:GetEquipGroup()
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从装备怪兽的装备区中选择1至ft张满足特殊召唤条件的「异热同心武器」怪兽（ft为可用的怪兽区数量）。
	local g=Duel.SelectMatchingCard(tp,c2896663.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,ft,nil,e,tp,eqg)
	if g:GetCount()>0 then
		-- 将选择的「异热同心武器」怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
