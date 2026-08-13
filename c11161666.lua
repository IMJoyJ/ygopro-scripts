--御巫奉サナキ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己场上1张「御巫」卡为对象才能发动。那张卡回到手卡。
-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1只幻想魔族以外的「御巫」怪兽特殊召唤。这个回合，自己不是「御巫」怪兽不能从额外卡组特殊召唤。
-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 注册该卡的①②③三个效果：①起动效果，取自己场上1张「御巫」卡返回手牌；②有装备卡装备时，从卡组特召1只非幻想魔族的「御巫」怪兽并附加额外特召限制；③被送去墓地时，取场上1只表侧表示怪兽将此卡作为装备卡装备。
function s.initial_effect(c)
	-- ①：以自己场上1张「御巫」卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1只幻想魔族以外的「御巫」怪兽特殊召唤。这个回合，自己不是「御巫」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_EQUIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"装备"
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
-- ①的取对象筛选条件：对象必须是表侧表示、属于「御巫」字段且可以被加入手卡。
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18d) and c:IsAbleToHand()
end
-- ①效果的发动阶段：选择自己场上1张满足条件的表侧表示「御巫」卡作为对象，并设定此次操作会将卡返回手牌的信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果发动合法性检查：自己场上是否存在至少1张符合条件的「御巫」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出“请选择要返回手牌的卡”的提示，供玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1张符合条件的「御巫」卡作为此效果的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁信息：本次效果将把1张卡返回持有者手牌（用于时点/效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：若对象仍与连锁相关，将其返回持有者手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 以效果原因将对象卡返回持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②特召对象的筛选条件：卡名属于「御巫」、不是幻想魔族、且能被这个效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsRace(RACE_ILLUSION)
end
-- ②发动条件检查与信息设定：自己的主要怪兽区有空位，且卡组中存在满足条件的「御巫」怪兽；并设定将从卡组特殊召唤1只怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只满足条件的「御巫」怪兽（非幻想魔族且可被特殊召唤）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：从卡组特殊召唤1只怪兽（具体对象处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若仍有空位则从卡组选1只符合条件的「御巫」怪兽特殊召唤；然后给自己附加“这个回合不能从额外卡组特殊召唤非「御巫」怪兽”的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认主要怪兽区有空位，防止因连锁导致格子变化而不能特召。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出“请选择要特殊召唤的卡”的提示，供玩家从卡组选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「御巫」怪兽用于特殊召唤。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧攻击表示特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是「御巫」怪兽不能从额外卡组特殊召唤。③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前玩家tp，效果持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：被限制特殊召唤的是来自额外卡组且不是「御巫」字段的怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x18d) and c:IsLocation(LOCATION_EXTRA)
end
-- ③发动条件检查：自己魔陷区有空格且场上存在表侧表示怪兽可作为对象；符合条件则选择装备对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查自己魔陷区是否有可用的格子用于装备这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在至少1只表侧表示怪兽可以作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要装备的卡”的提示，供玩家选择目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为这张卡的装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息：这张卡将从墓地离开并以装备卡形式上场，标记LEAVE_GRAVE。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ③效果处理：确认各条件后，将墓地中的这张卡作为装备魔法卡装备给目标怪兽，并附加只能装备给该怪兽的限制效果。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 取得③效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理前校验：魔陷区有空位、目标怪兽不为里侧、目标仍与连锁相关、此卡不违反同名卡限制，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToChain() or not c:CheckUniqueOnField(tp) then return end
	-- 尝试执行装备操作；若因故装备失败则中止后续处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 这张卡当作装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(s.eqlimit)
	e2:SetLabelObject(tc)
	c:RegisterEffect(e2)
end
-- 判定允许装备的对象：只有当初选择的目标怪兽才能装备这张卡（对应当作装备魔法卡给那只怪兽装备的限制）。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
