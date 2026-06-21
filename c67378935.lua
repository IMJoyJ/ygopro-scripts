--オーバーレイ・ネットワーク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●以自己场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选持有和那只怪兽相同等级的1只怪兽效果无效守备表示特殊召唤。这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ●以自己场上1只超量怪兽为对象才能发动。那只怪兽作为超量素材中的1张卡加入持有者手卡。
function c67378935.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以从以下效果选择1个发动。●以自己场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选持有和那只怪兽相同等级的1只怪兽效果无效守备表示特殊召唤。这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67378935,0))  --"相同等级的怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,67378935)
	e2:SetCost(c67378935.spcost)
	e2:SetTarget(c67378935.sptg)
	e2:SetOperation(c67378935.spop)
	c:RegisterEffect(e2)
	-- ●以自己场上1只超量怪兽为对象才能发动。那只怪兽作为超量素材中的1张卡加入持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67378935,1))  --"超量素材加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,67378935)
	e3:SetTarget(c67378935.thtg)
	e3:SetOperation(c67378935.thop)
	c:RegisterEffect(e3)
	-- 添加特殊召唤的活动计数器，监控玩家在额外卡组特殊召唤非超量怪兽的行为
	Duel.AddCustomActivityCounter(67378935,ACTIVITY_SPSUMMON,c67378935.counterfilter)
end
-- 活动计数器的过滤函数，特殊召唤非额外卡组的怪兽或表侧表示的超量怪兽不计入次数
function c67378935.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 特殊召唤效果发动的Cost函数，检查本回合特召限制并注册只能特召超量怪兽的誓约效果
function c67378935.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当chk为0时，检查玩家本回合从额外卡组特殊召唤非超量怪兽的次数是否为0
	if chk==0 then return Duel.GetCustomActivityCount(67378935,tp,ACTIVITY_SPSUMMON)==0 end
	-- ●以自己场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选持有和那只怪兽相同等级的1只怪兽效果无效守备表示特殊召唤。这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c67378935.splimit)
	-- 为玩家注册本回合不能从额外卡组特殊召唤超量怪兽以外怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件，只限制从额外卡组特殊召唤非超量怪兽
function c67378935.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 选择对象的过滤函数：自己场上表侧表示且等级在1以上的怪兽，且手卡或墓地有与其等级相同的可特召怪兽
function c67378935.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(1)
		-- 确认自己手卡或墓地存在能与该怪兽等级相同且可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c67378935.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
-- 用于特殊召唤的过滤函数：等级等于lv且可以守备表示特殊召唤的怪兽
function c67378935.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的Target函数，检查自己场上的空格和符合效果的对象怪兽
function c67378935.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67378935.cfilter(chkc,e,tp) end
	-- 当chk为0时，检查自己场上是否留有至少1个空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己场上存在可以作为效果对象的合法怪兽
		and Duel.IsExistingTarget(c67378935.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向对方玩家提示自己发动了哪一项效果分支
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择作为该效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c67378935.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果分类为特殊召唤，数量为1，范围为手卡或墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的Operation函数，在手卡或墓地选择与对象相同等级的怪兽，使其效果无效且守备表示特殊召唤
function c67378935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上已无空余的怪兽区域，则直接结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认效果对象仍在场上表侧表示存在，且自己场上依然有空余的怪兽区域
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或墓地选择1只与对象怪兽相同等级的怪兽（受王家长眠之谷过滤影响）
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c67378935.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLevel()):GetFirst()
		-- 如果成功选出怪兽，则执行将其表侧守备表示特殊召唤的操作步骤
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的最终结算处理
		Duel.SpecialSummonComplete()
	end
end
-- 过滤函数，检查自己场上的怪兽是否为拥有超量素材的表侧表示超量怪兽
function c67378935.thfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayCount()>0
end
-- 回收超量素材效果的Target函数，进行合法对象的判定与选择
function c67378935.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67378935.thfilter(chkc) end
	-- 在chk为0时，检查自己场上是否存在持有超量素材的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c67378935.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示自己发动的效果分支
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的表侧表示超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c67378935.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果分类为加入手卡，操作目标为超量素材区域的卡片
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
-- 回收超量素材效果的Operation函数，从对象超量怪兽的素材中选择一张加入持有者手卡
function c67378935.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的表侧表示超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=og:Select(tp,1,1,nil)
			-- 将选择的超量素材卡加入持有者的手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
