--E-HERO ヴィシャス・クローズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：以场上1只「英雄」怪兽为对象才能发动。这张卡从手卡守备表示特殊召唤，作为对象的怪兽的攻击力上升300。
-- ②：自己场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从墓地特殊召唤。那之后，自己墓地有着有「暗黑融合」的卡名记述的怪兽存在的场合，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 创建卡牌效果，注册两个效果：①从手卡特殊召唤并提升攻击力；②从墓地特殊召唤并可能破坏场上一张卡
function s.initial_effect(c)
	-- 记录该卡具有「暗黑融合」的卡名记述
	aux.AddCodeList(c,94820406)
	-- 效果①：以场上1只「英雄」怪兽为对象才能发动。这张卡从手卡守备表示特殊召唤，作为对象的怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：自己场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从墓地特殊召唤。那之后，自己墓地有着有「暗黑融合」的卡名记述的怪兽存在的场合，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「英雄」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 效果①的发动条件判断：手卡可以特殊召唤，场上存在「英雄」怪兽，且有足够召唤位置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 判断场上是否有足够召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在符合条件的「英雄」怪兽
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的「英雄」怪兽作为对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：将该卡特殊召唤并提升对象怪兽攻击力
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断该卡是否可以特殊召唤并成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 为对象怪兽增加300攻击力
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(300)
			tc:RegisterEffect(e1)
	end
end
-- 过滤条件：被战斗或效果破坏且之前在自己场上的怪兽
function s.cspfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 效果②的发动条件判断：有怪兽被破坏且不是自己
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cspfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动条件判断：墓地可以特殊召唤且有足够召唤位置
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置效果处理信息：将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：墓地有「暗黑融合」的怪兽
function s.cdesfilter(c)
	-- 判断墓地是否存在「暗黑融合」的怪兽
	return aux.IsCodeListed(c,94820406) and c:IsType(TYPE_MONSTER)
end
-- 效果②的处理：将该卡特殊召唤并可能破坏场上一张卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否可以特殊召唤并成功特殊召唤
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断墓地是否存在「暗黑融合」的怪兽
		and Duel.IsExistingMatchingCard(s.cdesfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 判断场上是否存在可破坏的卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否破坏场上一张卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示被选为对象的卡
			Duel.HintSelection(g)
			-- 将选中的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
