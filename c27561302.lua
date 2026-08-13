--雨の天気模様
-- 效果：
-- ①：「雨之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●把这张卡除外，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
function c27561302.initial_effect(c)
	c:SetUniqueOnField(1,0,27561302)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「●把这张卡除外，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。」此处创建该诱发即时效果并设置其分类、类型、取对象标志、自由时点发动、仅在主要怪兽区域生效，以及代价、发动条件和处理函数。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27561302,0))  --"魔法·陷阱卡回到持有者手卡（雨之天气模样）"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	-- 设置发动代价为“把这张卡除外”，使用辅助函数aux.bfgcost，在发动前将这张天气模样除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27561302.thtg)
	e2:SetOperation(c27561302.thop)
	-- 「②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。」此处创建授予效果：当这张卡在魔陷区时，对符合条件的我方主要怪兽区域中的天气效果怪兽授予e2所代表的发动效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c27561302.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判定哪些怪兽能被授予效果：必须是主要怪兽区域（序号0-4）的「天气」效果怪兽，且其纵向列与这张天气模样的纵向列相同或左右相邻（序号差绝对值≤1）。
function c27561302.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 定义对象过滤函数：选择对方场上的魔法·陷阱卡，且该卡可以加入手卡。
function c27561302.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动处理的目标选择函数：先进行取对象合法性校验，确认场上存在可选择的对方魔陷；随后向对方提示所发动效果，并让己方选择1张对方场上的魔法·陷阱卡作为对象，同时设定操作信息为回手牌。
function c27561302.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c27561302.thfilter(chkc) end
	-- 在发动时检查是否存在至少1张符合条件的对方场上魔法·陷阱卡，可作为效果对象；不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c27561302.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示“对方选择了”该效果的描述信息，用于连锁确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向自己玩家显示选择提示，要求从对方场上选择1张要返回手牌的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 由自己玩家从对方场上选择1张满足条件的魔法·陷阱卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c27561302.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次操作信息设定为“回手牌”分类，对象为已选卡，数量为1，供后续效果联动和防止错过时点使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：取得连锁发动时选择的对象卡片，若该卡仍与效果有联系，则将其送入持有者手卡。
function c27561302.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动时所选择的对象卡（此处为对方场上1张魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者的手卡，实现“那张卡回到持有者手卡”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
