--アブダクション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。原本种族、原本属性和原本的等级·阶级·连接是和作为对象的怪兽相同的1只怪兽从卡组·额外卡组除外，得到作为对象的怪兽的控制权。把原本卡名和作为对象的怪兽相同的怪兽用这个效果除外的场合，这个效果得到控制权的怪兽的效果无效化。
local s,id,o=GetID()
-- 注册效果：将此卡设为发动时点效果，可选择对象，发动次数限制为1次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否可以改变控制权且正面表示
function s.cfilter(c,tp)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
		-- 判断对方场上是否存在满足条件的怪兽可被除外
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c)
end
-- 判断卡牌是否满足种族、属性、等级/阶级/连接与目标怪兽相同且可除外
function s.rmfilter(c,ec)
	local eq=false
	if c:IsAllTypes(TYPE_LINK+TYPE_MONSTER) then
		eq=ec:IsAllTypes(TYPE_LINK+TYPE_MONSTER) and c:GetLink()==ec:GetLink()
	elseif c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER) then
		eq=ec:IsAllTypes(TYPE_XYZ+TYPE_MONSTER) and c:GetOriginalRank()==ec:GetOriginalRank()
	else
		eq=c:GetOriginalLevel()==ec:GetOriginalLevel()
	end
	return eq and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
		and c:GetOriginalRace()&ec:GetOriginalRace()~=0
		and c:GetOriginalAttribute()&ec:GetOriginalAttribute()~=0
end
-- 设置效果目标：选择对方场上一只正面表示且可改变控制权的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.cfilter(chkc,tp) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：将目标怪兽的控制权变更加入连锁处理
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：将从卡组/额外卡组除外的怪兽加入连锁处理
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理函数：执行效果，选择目标怪兽并进行控制权变更和除外操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从卡组/额外卡组中选择满足条件的怪兽进行除外
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc)
		-- 确认除外成功并处理后续效果
		if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			local rc=g:GetFirst()
			-- 若控制权变更成功且目标怪兽与除外怪兽卡号相同，则使目标怪兽效果无效
			if Duel.GetControl(tc,tp)~=0 and tc:GetOriginalCode()==rc:GetOriginalCode() then
				-- 使目标怪兽效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 使目标怪兽效果无效化
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end
