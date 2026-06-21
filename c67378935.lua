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
	-- 以自己场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选持有和那只怪兽相同等级的1只怪兽效果无效守备表示特殊召唤。这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤。
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
	-- 以自己场上1只超量怪兽为对象才能发动。那只怪兽作为超量素材中的1张卡加入持有者手卡。
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
	-- 注册一个自定义活动计数器，用于检测本回合玩家从额外卡组特殊召唤非超量怪兽的动作
	Duel.AddCustomActivityCounter(67378935,ACTIVITY_SPSUMMON,c67378935.counterfilter)
end
-- 计数器的过滤函数，当特殊召唤的怪兽不是从额外卡组特殊召唤，或者是超量怪兽时返回true（不计入非超量额外特召的次数）
function c67378935.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 效果①选择第一个效果发动时的Cost函数，用于检测并添加“本回合自己不是超量怪兽不能从额外卡组特殊召唤”的限制
function c67378935.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查本回合至今为止是否没有进行过不符合条件的特殊召唤（即没有从额外卡组特殊召唤过非超量怪兽）
	if chk==0 then return Duel.GetCustomActivityCount(67378935,tp,ACTIVITY_SPSUMMON)==0 end
	-- 以自己场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选持有和那只怪兽相同等级的1只怪兽效果无效守备表示特殊召唤。这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c67378935.splimit)
	-- 给玩家注册“不能从额外卡组特殊召唤非超量怪兽”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，限制从额外卡组特殊召唤非超量怪兽
function c67378935.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 对象的过滤条件：自己场上表侧表示且有等级的怪兽，并且手卡或墓地存在至少1只与其等级相同且能特殊召唤的怪兽
function c67378935.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(1)
		-- 检查手卡或墓地是否存在至少1只与该怪兽等级相同的、可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c67378935.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
-- 特殊召唤怪兽的过滤条件：等级与指定等级相同，且可以以守备表示特殊召唤
function c67378935.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①选择第一个效果发动时的Target（目标选择）函数
function c67378935.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67378935.cfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在可以作为对象、且满足后续特召条件的表侧表示怪兽
		and Duel.IsExistingTarget(c67378935.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向对方玩家提示当前发动的效果（选择第一个效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c67378935.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①选择第一个效果发动时的Operation（效果处理）函数
function c67378935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否仍在场上表侧表示存在，且自己场上仍有可用的怪兽区域
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡或墓地（受王家之谷影响）选择1只与对象怪兽相同等级的怪兽
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c67378935.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLevel()):GetFirst()
		-- 若成功选出怪兽，则将其以表侧守备表示特殊召唤（分步处理）
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
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 对象的过滤条件：自己场上表侧表示且拥有超量素材的超量怪兽
function c67378935.thfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayCount()>0
end
-- 效果①选择第二个效果发动时的Target（目标选择）函数
function c67378935.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67378935.thfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象、且拥有超量素材的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c67378935.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示当前发动的效果（选择第二个效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择作为效果对象的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只表侧表示且拥有超量素材的超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c67378935.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表明该效果包含将超量素材加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
-- 效果①选择第二个效果发动时的Operation（效果处理）函数
function c67378935.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 提示玩家选择要加入手牌的超量素材
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=og:Select(tp,1,1,nil)
			-- 将选中的超量素材加入持有者的手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
