--バックアップ・オペレーター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己的连接怪兽的所连接区1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到持有者手卡。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c97947705.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以自己的连接怪兽的所连接区1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到持有者手卡。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97947705,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,97947705)
	e1:SetTarget(c97947705.sptg)
	e1:SetOperation(c97947705.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的连接怪兽
function c97947705.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 过滤属于连接怪兽所连接区的、表侧表示且能回到手牌的怪兽
function c97947705.thfilter(c,g)
	return c:IsFaceup() and g:IsContains(c) and c:IsAbleToHand()
end
-- 效果①的发动准备与条件判定：获取自己场上所有连接怪兽所连接区的怪兽集合，并确认手卡中此卡可特殊召唤、场上有空位且存在可作为对象的怪兽
function c97947705.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Group.CreateGroup()
	-- 获取自己场上所有的表侧表示连接怪兽
	local lg=Duel.GetMatchingGroup(c97947705.lkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历自己场上的所有连接怪兽
	for tc in aux.Next(lg) do
		tg:Merge(tc:GetLinkedGroup())
	end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c97947705.thfilter(chkc,tg) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定自己场上是否有可用于特殊召唤怪兽的空余怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定场上是否存在至少1只符合条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c97947705.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tg) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97947705.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tg)
	-- 设置连锁信息，声明该效果包含将选中的对象怪兽送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁信息，声明该效果包含将手牌中的此卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将此卡从手卡特殊召唤，并为该卡添加离场时除外的限制，然后将作为对象的怪兽送回持有者手牌
function c97947705.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤，若特殊召唤成功则继续处理后续效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 作为对象的怪兽回到持有者手卡。这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 获取在发动时选择的作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 通过效果将目标怪兽送回持有者的手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
