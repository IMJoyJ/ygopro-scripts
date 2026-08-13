--ライト・リサイレンス
-- 效果：
-- 每次名字带有「光道」的怪兽的效果从自己卡组把卡送去墓地，从对方卡组上面把1张卡从游戏中除外。
function c35577420.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次名字带有「光道」的怪兽的效果从自己卡组把卡送去墓地，从对方卡组上面把1张卡从游戏中除外。
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
-- 筛选出此次被送去墓地的卡中，此前所在位置为卡组的卡（即从卡组被送去墓地的卡）。
function c35577420.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果发动条件：当“光道”怪兽的效果由自己发动并把卡从自己卡组送去墓地时，判定该效果的控制者为自己、原因为效果、发动来源为光道怪兽，且本次送入墓地的卡中存在来自卡组的卡，满足条件则本效果可以发动。
function c35577420.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rp==tp and bit.band(r,REASON_EFFECT)~=0 and rc:IsSetCard(0x38) and rc:IsType(TYPE_MONSTER)
		and eg:IsExists(c35577420.cfilter,1,nil)
end
-- 效果发动时的目标处理：本效果不取对象，因此只要条件满足即可返回true允许发动；随后设置除外对方卡组顶1张卡的操作信息。
function c35577420.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁处理的操作信息：除外卡组的卡，不指定具体卡片，数量为1，供其他卡牌互动时查询。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的具体操作：若对方卡组没有卡则终止；否则取出对方卡组最上方1张，禁止洗切检测后将其除外。
function c35577420.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方卡组是否有卡，若对方卡组为空则无法进行除外，直接终止处理。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 取得对方卡组最上方的那1张卡（以组对象g表示）。
	local g=Duel.GetDecktopGroup(1-tp,1)
	-- 禁用本次操作的系统自动洗切卡组检测，因为从卡组顶端依次除外不需要洗切卡组。
	Duel.DisableShuffleCheck()
	-- 将取出的那张卡以表侧表示从游戏中除外，除外原因视为效果。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
