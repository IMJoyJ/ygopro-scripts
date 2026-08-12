--S-Force ソート・ワールド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：为让自己场上的「治安战警队」怪兽的效果发动而把手卡除外的场合，可以作为代替从卡组把「治安战警队多世界排序」以外的1张「治安战警队」卡送去墓地。
-- ②：其他卡被除外的场合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。那之后，可以让自己场上1只「治安战警队」怪兽的位置向其他的自己的主要怪兽区域移动。
local s,id,o=GetID()
-- 注册卡片效果的入口函数，初始化卡片效果（注册魔陷卡发动效果e1，代替除外永续效果e2，其他卡除外时除外敌方卡片并可选移动怪兽的诱发效果e3）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：为让自己场上的「治安战警队」怪兽的效果发动而把手卡除外的场合，可以作为代替从卡组把「治安战警队多世界排序」以外的1张「治安战警队」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.target)
	e2:SetTargetRange(LOCATION_DECK,0)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	-- ②：其他卡被除外的场合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。那之后，可以让自己场上1只「治安战警队」怪兽的位置向其他的自己的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 代替除外效果的过滤目标函数，限定为自己卡组的卡。
function s.target(e,c)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(e:GetHandlerPlayer())
end
-- 判定是否有除此卡以外的其他卡被除外，以作为效果发动的条件。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被除外的卡片中是否存在除这张卡以外的卡。
	return eg:IsExists(aux.TRUE,1,e:GetHandler())
end
-- 选择对方场上或墓地的一张卡为对象，并设置除外操作信息的发动与对象选择函数。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	-- 确认对方场上或墓地是否存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 给玩家发送选择除外卡片的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择对方场上或墓地中的1张可除外的卡作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置连锁操作信息，声明当前效果包含将选中的卡除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 筛选自己场上表侧表示「治安战警队」怪兽的过滤函数。
function s.eqfiltter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x156)
end
-- 效果处理函数，负责将对象卡除外，并在满足条件时，询问玩家是否移动己方场上「治安战警队」怪兽的位置并执行移动。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍然与当前连锁关联，且不受王家长眠之谷等限制墓地卡片的效果影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 执行将对象卡表侧表示除外的处理，并判定是否成功除外了至少1张卡。
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		-- 检查自己场上是否存在表侧表示的「治安战警队」怪兽。
		and Duel.IsExistingMatchingCard(s.eqfiltter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上的主要怪兽区域是否还有可用的空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 询问玩家是否决定将自己场上1只「治安战警队」怪兽的位置移动。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要移动位置？"
		-- 中断当前效果处理，使后续的移动位置处理与除外处理不视为同时进行。
		Duel.BreakEffect()
		-- 发送系统提示，要求玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家选择自己场上的1只表侧表示的「治安战警队」怪兽。
		local mc=Duel.SelectMatchingCard(tp,s.eqfiltter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		-- 发送系统提示，要求玩家选择要移动到的位置。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让玩家选择自己场上主要怪兽区域中1个可用的空格并返回其位置标记。
		local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		-- 在场上闪烁显示选中的怪兽以提示被操作的卡。
		Duel.HintSelection(Group.FromCards(mc))
		-- 在所选的位置格子高亮提示，显示怪兽即将移动到的目标区域。
		Duel.Hint(HINT_ZONE,tp,fd)
		local seq=math.log(fd,2)
		-- 将选择的怪兽卡移动到选定的新怪兽区域位置。
		Duel.MoveSequence(mc,seq)
	end
end
