--A宝玉獣 ルビー・カーバンクル
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：这张卡是当作永续魔法卡使用的场合才能发动。这张卡特殊召唤。那之后，可以把自己的魔法与陷阱区域的「高等宝玉兽」怪兽卡尽可能特殊召唤。
function c83575471.initial_effect(c)
	-- 注册卡片关联密码「高等暗黑结界」（12644061）。
	aux.AddCodeList(c,12644061)
	-- 开启全局不入连锁的自我送墓检查标记。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(c83575471.tgcon)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c83575471.repcon)
	e2:SetOperation(c83575471.repop)
	c:RegisterEffect(e2)
	-- ③：这张卡是当作永续魔法卡使用的场合才能发动。这张卡特殊召唤。那之后，可以把自己的魔法与陷阱区域的「高等宝玉兽」怪兽卡尽可能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,83575471)
	e3:SetCondition(c83575471.spcon)
	e3:SetTarget(c83575471.sptg)
	e3:SetOperation(c83575471.spop)
	c:RegisterEffect(e3)
end
-- 定义效果①（不入连锁送墓）的生效条件函数。
function c83575471.tgcon(e)
	-- 检查场地区域是否存在「高等暗黑结界」，若不存在则满足送墓条件。
	return not Duel.IsEnvironment(12644061)
end
-- 定义效果②（被破坏时当作永续魔法放置）的条件函数：在怪兽区域表侧表示被破坏。
function c83575471.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 定义效果②（被破坏时当作永续魔法放置）的操作函数：将其作为永续魔法卡在魔陷区表侧表示放置。
function c83575471.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 定义效果③（特殊召唤）的发动条件函数：这张卡当作永续魔法卡使用。
function c83575471.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 定义效果③（特殊召唤）的发动准备与合法性检测函数。
function c83575471.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤魔陷区中表侧表示、可以特殊召唤的「高等宝玉兽」怪兽卡。
function c83575471.filter(c,e,sp)
	return c:IsFaceup() and c:IsSetCard(0x5034) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 定义效果③（特殊召唤）的效果处理函数。
function c83575471.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试将自身以表侧表示特殊召唤（作为多卡特殊召唤的第一步）。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 获取自己场上剩余的可用怪兽区域空格数量。
			local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
			if ct<=0 then
				-- 完成特殊召唤的结算（若没有多余空格，则直接结束特召流程）。
				Duel.SpecialSummonComplete()
				return
			end
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 获取自己魔法与陷阱区域所有符合条件的「高等宝玉兽」怪兽卡。
			local g=Duel.GetMatchingGroup(c83575471.filter,tp,LOCATION_SZONE,0,nil,e,tp)
			local gc=g:GetCount()
			-- 若存在符合条件的卡，询问玩家是否继续特殊召唤魔陷区的「高等宝玉兽」怪兽。
			if gc>0 and Duel.SelectYesNo(tp,aux.Stringid(83575471,0)) then  --"是否尽可能特殊召唤？"
				-- 暂时关闭卡片的自爆检查（防止在特召过程中因场地卡不存在而立即自爆）。
				Duel.DisableSelfDestroyCheck()
				-- 完成自身特殊召唤的结算。
				Duel.SpecialSummonComplete()
				-- 中断当前效果，使后续的特殊召唤视为不同时处理（“那之后”）。
				Duel.BreakEffect()
				if gc<=ct then
					-- 将所有符合条件的「高等宝玉兽」怪兽卡特殊召唤到自己场上。
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				else
					-- 提示玩家选择要特殊召唤的卡片。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:Select(tp,ct,ct,nil)
					-- 将玩家选择的、数量不超过可用格子上限的「高等宝玉兽」怪兽卡特殊召唤。
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
				-- 重新启用卡片的自爆检查。
				Duel.DisableSelfDestroyCheck(false)
			else
				-- 完成特殊召唤的结算（玩家选择不特殊召唤其他怪兽时的处理）。
				Duel.SpecialSummonComplete()
			end
		else
			-- 完成特殊召唤的结算（自身特殊召唤失败时的处理）。
			Duel.SpecialSummonComplete()
		end
	end
end
