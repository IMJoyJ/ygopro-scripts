--破械神シュヤーマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。那之后，可以把场上1张魔法·陷阱卡破坏。
-- ②：这张卡在墓地存在的场合，以自己场上1只恶魔族怪兽或1张里侧表示卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
function c88554436.initial_effect(c)
	-- ①：以自己场上1张卡为对象才能发动。那张卡破坏。那之后，可以把场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88554436,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88554436)
	e1:SetTarget(c88554436.destg)
	e1:SetOperation(c88554436.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只恶魔族怪兽或1张里侧表示卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,88554437)
	e2:SetTarget(c88554436.spdtg)
	e2:SetOperation(c88554436.spdop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动条件判定与目标选择
function c88554436.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	-- 判定自己场上是否存在可以作为对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张卡作为破坏的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁信息：包含破坏效果，对象为选择的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①号效果的处理：破坏对象卡，并可选破坏场上1张魔法·陷阱卡
function c88554436.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第一个（也是唯一的）对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关联，则将其破坏，并判定是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取场上除已被破坏的卡以外的所有魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,TYPE_SPELL+TYPE_TRAP)
		-- 若存在可破坏的魔法·陷阱卡，询问玩家是否进行破坏
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(88554436,1)) then  --"是否把场上1张魔法·陷阱卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理不与前面的破坏同时进行（造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g:Select(tp,1,1,nil)
			-- 在场上对选择的卡片显示选中特效
			Duel.HintSelection(dg)
			-- 破坏选择的魔法·陷阱卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己场上表侧表示的恶魔族怪兽，或里侧表示的卡，且该卡离开后能留出怪兽区域
function c88554436.desfilter(c,tp)
	return (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_FIEND) or c:IsFacedown())
		-- 判定该卡离开场上后，是否能腾出可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- ②号效果的发动准备：判定自身能否特殊召唤，并选择自己场上1张符合条件的卡作为破坏对象
function c88554436.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c88554436.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定自己场上是否存在满足条件的恶魔族怪兽或里侧表示卡作为对象
		and Duel.IsExistingTarget(c88554436.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只恶魔族怪兽或1张里侧表示卡作为破坏的对象
	local g=Duel.SelectTarget(tp,c88554436.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置连锁信息：包含破坏效果，对象为选择的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含特殊召唤效果，目标为墓地的这张卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②号效果的处理：破坏对象卡，特殊召唤自身，并添加离场时回到卡组最下面的限制
function c88554436.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取第一个（也是唯一的）对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关联，则将其破坏，并判定是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 若自身仍与效果相关联，则将自身以表侧表示特殊召唤，并判定是否特殊召唤成功
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)
	end
end
