--マジカル・ハウンド
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡，这张卡特殊召唤。
function c51916853.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、属性、适用区域、使用次数限制、目标选择函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51916853,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,51916853+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(c51916853.sptg)
	e1:SetOperation(c51916853.spop)
	c:RegisterEffect(e1)
end
-- 过滤器函数，用于判断对象卡是否为正面表示的魔法·陷阱卡且能送入手牌
function c51916853.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果的目标选择函数，判断是否满足发动条件并设置目标
function c51916853.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c51916853.cfilter(chkc) end
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否存在符合条件的魔法·陷阱卡作为目标
		and Duel.IsExistingTarget(c51916853.cfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择符合条件的对方场上的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c51916853.cfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，指定将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息，指定将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将目标卡送回手牌并特殊召唤自身的操作
function c51916853.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡和自身是否仍然在场上且满足处理条件
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		and c:IsRelateToEffect(e) then
		-- 将自身以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
