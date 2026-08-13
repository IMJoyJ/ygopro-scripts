--アブダクション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。原本种族、原本属性和原本的等级·阶级·连接是和作为对象的怪兽相同的1只怪兽从卡组·额外卡组除外，得到作为对象的怪兽的控制权。把原本卡名和作为对象的怪兽相同的怪兽用这个效果除外的场合，这个效果得到控制权的怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化效果：创建并注册该卡的魔法卡发动效果（‘绑架事件’的①效果），该效果为取对象的控制权变更+除外效果，类型为通常魔法发动，自由时点，1回合只能发动1张，并指定发动条件/处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只表侧表示怪兽为对象才能发动。原本种族、原本属性和原本的等级·阶级·连接是和作为对象的怪兽相同的1只怪兽从卡组·额外卡组除外，得到作为对象的怪兽的控制权。把原本卡名和作为对象的怪兽相同的怪兽用这个效果除外的场合，这个效果得到控制权的怪兽的效果无效化。
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
-- 判断对方场上表侧表示怪兽是否能成为效果对象：控制权可变更且表侧表示，并且我方卡组·额外卡组存在满足s.rmfilter条件的可除外怪兽。
function s.cfilter(c,tp)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
		-- 检查我方卡组·额外卡组是否存在至少1张满足s.rmfilter条件（即与候选对象怪兽的原本种族、原本属性及等级/阶级/连接相同）的怪兽，以确保能够除外。
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c)
end
-- 定义可除外的怪兽筛选条件：被选中除外的怪兽必须与对象怪兽同为怪兽，且原本种族、原本属性有交集，并根据对象怪兽的种类比较原本等级（通常）、原本阶级（超量）或连接标记（连接）是否相同；同时该怪兽可以被除外。
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
-- 效果发动的目标选择阶段：确认可以选择对方场上1只表侧表示且满足条件的怪兽作为対象；弹出选择提示；玩家选择对象；然后设置操作信息：将获得对象控制权，并除外1张符合条件的卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.cfilter(chkc,tp) end
	-- 无连锁时为发动检查：若对方场上不存在满足s.cfilter条件（可变更控制权且能除外对应卡）的表侧怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向操作玩家显示‘请选择要改变控制权的怪兽’的提示文字，用于卡片选择界面的说明。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只满足s.cfilter条件的表侧表示怪兽作为效果对象，并记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：本连锁将改变所选对象的控制权（获取控制权），用于发动被无效等相关判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：本连锁将进行除外操作（预计除外1张，来自自己卡组·额外卡组），但由于具体除外卡在处理时才选择，所以对象设为nil。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理：验证对象仍是表侧怪兽且与效果关联；选择并除外1张满足条件的怪兽；若除外成功且成功获得对象控制权，且两者原卡名相同，则对对象附加效果无效和效果无效化处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽（当前连锁中第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 向操作玩家显示‘请选择要除外的卡’的提示文字，用于选择除外卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己的卡组·额外卡组中选择1张满足s.rmfilter条件（与对象怪兽原本种族、属性及等级/阶级/连接相同）的怪兽卡。
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc)
		-- 如果选择了卡，并且该卡以表侧表示被效果成功除外，则进入后续控制权获得及无效化处理。
		if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			local rc=g:GetFirst()
			-- 如果成功获得对象怪兽的控制权，并且对象怪兽的原本卡名与被除外的怪兽的原本卡名相同，则进行无效化处理。
			if Duel.GetControl(tc,tp)~=0 and tc:GetOriginalCode()==rc:GetOriginalCode() then
				-- 把原本卡名和作为对象的怪兽相同的怪兽用这个效果除外的场合，这个效果得到控制权的怪兽的效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 把原本卡名和作为对象的怪兽相同的怪兽用这个效果除外的场合，这个效果得到控制权的怪兽的效果无效化。
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
