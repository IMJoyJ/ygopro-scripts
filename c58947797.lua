--ヴァンパイア・デューク
-- 效果：
-- 「吸血鬼公爵」的②的效果1回合只能使用1次。把这张卡作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。
-- ①：这张卡召唤成功时，以自己墓地1只暗属性「吸血鬼」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡特殊召唤成功时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方把宣言的种类的1张卡从卡组送去墓地。
function c58947797.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只暗属性「吸血鬼」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58947797,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c58947797.sptg)
	e1:SetOperation(c58947797.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功时，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方把宣言的种类的1张卡从卡组送去墓地。「吸血鬼公爵」的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58947797,1))  --"宣言"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,58947797)
	e2:SetTarget(c58947797.tgtg)
	e2:SetOperation(c58947797.tgop)
	c:RegisterEffect(e2)
	-- 把这张卡作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetValue(c58947797.xyzlimit)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以守备表示特殊召唤的暗属性「吸血鬼」怪兽
function c58947797.filter(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①（召唤成功时特召墓地怪兽）的发动准备与目标选择
function c58947797.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c58947797.filter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足条件的暗属性「吸血鬼」怪兽
		and Duel.IsExistingTarget(c58947797.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的暗属性「吸血鬼」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58947797.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①（召唤成功时特召墓地怪兽）的效果处理
function c58947797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②（特召成功时宣言种类送墓）的发动准备与宣言卡片种类
function c58947797.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让发动效果的玩家宣言一个卡片种类（怪兽·魔法·陷阱）
	local op=Duel.AnnounceType(tp)
	e:SetLabel(bit.lshift(1,op))
	-- 设置效果处理信息为将对方卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤对方卡组中属于宣言种类的且能送去墓地的卡
function c58947797.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- 效果②（特召成功时宣言种类送墓）的效果处理
function c58947797.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让对方玩家从自身卡组选择1张属于宣言种类的卡
	local g=Duel.SelectMatchingCard(1-tp,c58947797.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 限制作为超量素材时，只能用于暗属性怪兽的超量召唤
function c58947797.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
