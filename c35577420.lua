--ライト・リサイレンス
-- 效果：
-- 每次名字带有「光道」的怪兽的效果从自己卡组把卡送去墓地，从对方卡组上面把1张卡从游戏中除外。
function c35577420.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个诱发必发效果，用于检测对方怪兽效果将卡送去墓地时触发，将对方卡组最上方一张卡除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetDescription(aux.Stringid(35577420,0))  --"对方卡组上面1张卡从游戏中除外"
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c35577420.rmcon)
	e2:SetTarget(c35577420.rmtg)
	e2:SetOperation(c35577420.rmop)
	c:RegisterEffect(e2)
end
-- 检查送入墓地的卡是否来自卡组
function c35577420.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 判断是否为对方怪兽效果送入墓地，且该怪兽属于光道卡组、为怪兽类型，并且有来自卡组的卡被送去墓地
function c35577420.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rp==tp and bit.band(r,REASON_EFFECT)~=0 and rc:IsSetCard(0x38) and rc:IsType(TYPE_MONSTER)
		and eg:IsExists(c35577420.cfilter,1,nil)
end
-- 设置效果处理时的操作信息，确定将要除外对方卡组最上方的一张卡
function c35577420.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要除外对方卡组最上方的一张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作，从对方卡组最上方除外一张卡
function c35577420.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方卡组是否为空，若为空则不执行除外操作
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 获取对方卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	-- 禁用洗切卡组检查，确保除外操作不会触发洗牌
	Duel.DisableShuffleCheck()
	-- 将指定卡以正面表示形式除外，原因设为效果
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
