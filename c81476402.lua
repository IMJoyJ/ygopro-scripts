--邪悪龍エビルナイト・ドラゴン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己的手卡·场上1只暗属性怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被战斗破坏时，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的①和②效果
function s.initial_effect(c)
	-- ①：把自己的手卡·场上1只暗属性怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏时，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。那之后，可以把这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤可解放的暗属性怪兽的条件函数
function s.rfilter(c,tp)
	-- 检查解放该卡后是否能空出怪兽区域，且该卡是暗属性，且在场上表侧表示或在手卡
	return Duel.GetMZoneCount(tp,c)>0 and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsFaceup() or c:IsControler(tp))
end
-- ①效果的发动代价（Cost）函数，执行解放1只暗属性怪兽的操作
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家手卡或场上是否存在至少1只满足过滤条件的可解放怪兽作为发动代价
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.rfilter,1,REASON_COST,true,c,tp) end
	-- 给玩家发送提示信息，要求选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.rfilter,1,1,REASON_COST,true,c,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- ①效果的发动准备（Target）函数，检查自身是否能特殊召唤并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示此效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理（Operation）函数，将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动玩家的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动准备（Target）函数，选择对方场上1只怪兽作为对象，并根据自身位置动态调整效果分类
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息，表示此效果包含将选中的对象送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ②效果的效果处理（Operation）函数，将对象怪兽送去墓地，并可选择是否将自身特殊召唤
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并将其因效果送去墓地，且确认其成功到达墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查自身是否仍与效果相关，且不受王家长眠之谷的影响
		and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 检查玩家场上是否有空余的怪兽区域，且自身是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否选择将这张卡特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与前面的送去墓地处理不视为同时进行
		Duel.BreakEffect()
		-- 将这张卡以表侧表示特殊召唤到发动玩家的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
