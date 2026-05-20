--A BF－霧雨のクナイ
-- 效果：
-- ①：这张卡可以把自己场上1只「黑羽」怪兽解放从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
-- ②：1回合1次，以自己场上1只同调怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
function c70456282.initial_effect(c)
	-- ①：这张卡可以把自己场上1只「黑羽」怪兽解放从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c70456282.spcon)
	e1:SetTarget(c70456282.sptg)
	e1:SetOperation(c70456282.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只同调怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c70456282.lvtg)
	e2:SetOperation(c70456282.lvop)
	c:RegisterEffect(e2)
end
c70456282.treat_itself_tuner=true
-- 过滤用于特殊召唤解放的「黑羽」怪兽
function c70456282.spfilter(c,tp)
	return c:IsSetCard(0x33)
		-- 检查解放该怪兽后是否有可用的怪兽区域，且该怪兽必须由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件判定函数
function c70456282.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1只满足过滤条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c70456282.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数
function c70456282.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取并过滤出场上所有可解放的「黑羽」怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c70456282.spfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数
function c70456282.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	-- 这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且等级大于0的同调怪兽
function c70456282.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:GetLevel()>0
end
-- 等级变更效果的发动准备与目标选择函数
function c70456282.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c70456282.filter(chkc) end
	-- 检查自己场上是否存在符合条件的同调怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c70456282.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70456282.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让玩家宣言1到8的等级（不能是当前的等级），并将宣言的值保存在效果的Label中
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 等级变更效果的执行操作函数
function c70456282.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
