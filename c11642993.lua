--S-Force ソート・ワールド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：为让自己场上的「治安战警队」怪兽的效果发动而把手卡除外的场合，可以作为代替从卡组把「治安战警队多世界排序」以外的1张「治安战警队」卡送去墓地。
-- ②：其他卡被除外的场合，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。那之后，可以让自己场上1只「治安战警队」怪兽的位置向其他的自己的主要怪兽区域移动。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔法卡发动、卡组代替送墓效果、以及其他卡除外时除外敌方卡片并移动我方怪兽位置的效果
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
-- 代替送墓效果的过滤目标位置与控制权限定
function s.target(e,c)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(e:GetHandlerPlayer())
end
-- 效果②的发动条件判断（有除自身以外的其他卡片被除外）
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查除外事件中的卡片组里是否存在除自身之外的卡片
	return eg:IsExists(aux.TRUE,1,e:GetHandler())
end
-- 效果②的发动目标与合法性检测（优先选择对方场上或墓地中可以除外的卡片作为对象）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	-- 在进行合法性检测时，确认对方场上或墓地中是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择一张需要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方的场上或墓地中选择一张卡片作为效果的对象（优先从场上选择）
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置连锁处理信息：将选中的卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 过滤条件：自己场上表侧表示的「治安战警队」怪兽
function s.eqfiltter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x156)
end
-- 效果②的效果处理（将目标卡片除外，并可选择是否移动我方「治安战警队」怪兽的位置）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对方场上或墓地的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡片与该效果关联，且在考虑「王家长眠之谷」影响下依然合法
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.eqfiltter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上主要怪兽区域是否还存在可用于移动的空余格子
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 询问玩家是否要选择进行怪兽位置的移动
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要移动位置？"
		-- 中断当前效果的处理，使其与后续移动位置的处理在时点上不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择需要操作移动位置的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家选择自己场上一只符合条件的「治安战警队」怪兽
		local mc=Duel.SelectMatchingCard(tp,s.eqfiltter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		-- 提示玩家选择怪兽要移动到的目的地区域
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让玩家选择自己场上一个空闲的主要怪兽区域格子，并返回该格子的位置标记
		local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		-- 手动显示被移动的怪兽的卡片选择动画效果并记录为对象
		Duel.HintSelection(Group.FromCards(mc))
		-- 在游戏界面闪烁提示要移动到的目标怪兽格子区域
		Duel.Hint(HINT_ZONE,tp,fd)
		local seq=math.log(fd,2)
		-- 将选中的怪兽移动到目标位置的怪兽格中
		Duel.MoveSequence(mc,seq)
	end
end
