--飛龍炎サラマンドラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备。
-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「飞龙炎」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化效果注册：依次为②装备攻击力上升效果、①手卡/墓地自我装备效果、③被送墓检索效果
function s.initial_effect(c)
	-- 记录本卡效果文本中记载了「炎之剑士」（卡号45231177），供后续IsCodeListed判定使用
	aux.AddCodeList(c,45231177)
	-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.eqcon)
	e1:SetValue(700)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「飞龙炎」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索「飞龙炎」魔法·陷阱卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- ②装备效果的条件：获取装备对象，判断其是否为「炎之剑士」或记载有「炎之剑士」卡名的怪兽
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local qc=e:GetHandler():GetEquipTarget()
	-- 具体判定：装备对象卡名是45231177，或其效果文本记载着45231177
	return (qc:IsCode(45231177) or aux.IsCodeListed(qc,45231177))
end
-- 装备①的选择过滤条件：对象必须是表侧表示且为战士族怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ①的发动目标判定：确认取对象信息合法、自己魔陷区有空位、场上不存在同名卡限制、且存在符合条件的战士族怪兽可作为对象
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) and chkc~=c end
	-- 发动条件：自己的魔法与陷阱区域有空位可放置装备卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 发动条件：自己场上存在符合过滤条件的表侧表示战士族怪兽可作为取对象目标
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 向玩家显示选择装备对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧表示战士族怪兽作为效果对象，同时将该对象与当前连锁关联
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 当从墓地发动时，设置本效果涉及墓地的操作信息（用于王家长眠之谷等卡的对应检测）
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,0,0,0)
	end
end
-- ①效果处理：若本卡已不关联本次连锁，或装备条件不满足，则将本卡送去墓地并终止处理
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得发动时选择的装备对象卡
	local tc=Duel.GetFirstTarget()
	-- 装备失败的判定条件：魔陷区无空位、对象里侧表示、对象控制权不属于自己、对象不关联本次连锁、或同名卡限制不满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or tc:GetControler()~=tp
		or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 装备条件不满足时将本卡以效果原因送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备处理，尝试把本卡装备给对象；装备成功后才继续后续限制效果注册
	if not Duel.Equip(tp,c,tc) then return end
	-- 这张卡当作装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数：本卡只能装备给效果处理时记录的对象卡（LabelObject）
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ③检索的过滤条件：卡组中的「飞龙炎」魔法·陷阱卡且能够加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1ac) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ③的发动目标：检查卡组是否有符合条件的「飞龙炎」魔法·陷阱卡，并设置检索加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：卡组中存在至少1张符合条件的「飞龙炎」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理为从卡组将1张卡加入手卡（用于连锁检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：选择1张「飞龙炎」魔法·陷阱卡加入手卡，并让对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择加入手牌的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张符合条件的「飞龙炎」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
