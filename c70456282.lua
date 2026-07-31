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
-- 特召解放过滤条件：「黑羽」怪兽且解放后怪兽区有空位
function c70456282.spfilter(c,tp)
	return c:IsSetCard(0x33)
		-- 检查解放该卡后自己怪兽区是否有空位
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果特召条件检查：场上是否存在可解放的「黑羽」怪兽
function c70456282.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足特召条件的解放对象
	return Duel.CheckReleaseGroupEx(tp,c70456282.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- ①效果特召准备：选择自己场上1只「黑羽」怪兽解放
function c70456282.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上符合特召条件的「黑羽」怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c70456282.spfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①效果特召处理：解放选中的怪兽，并将自身当作调整使用
function c70456282.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的「黑羽」怪兽
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
-- 等级变更过滤条件：表侧表示且等级大于0的同调怪兽
function c70456282.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:GetLevel()>0
end
-- ②效果发动准备：选择自己场上1只同调怪兽为对象并宣言1~8的等级
function c70456282.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c70456282.filter(chkc) end
	-- 检查自己场上是否存在表侧表示的同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c70456282.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示同调怪兽作为对象
	local g=Duel.SelectTarget(tp,c70456282.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1~8中与原等级不同的等级
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- ②效果处理：将目标怪兽的等级变成宣言的等级
function c70456282.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁选中的目标同调怪兽
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
