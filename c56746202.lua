--スクラップ・キマイラ
-- 效果：
-- 把这张卡作为同调素材的场合，不是「废铁」怪兽的同调召唤不能使用，其他的同调素材怪兽必须全部是「废铁」怪兽。
-- ①：这张卡召唤成功时，以自己墓地1只「废铁」调整为对象才能发动。那只怪兽特殊召唤。
function c56746202.initial_effect(c)
	-- 开启废铁奇美拉的全局标记，用于处理其特殊的同调素材限制
	Duel.EnableGlobalFlag(GLOBALFLAG_SCRAP_CHIMERA)
	-- ①：这张卡召唤成功时，以自己墓地1只「废铁」调整为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56746202,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c56746202.sumtg)
	e1:SetOperation(c56746202.sumop)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是「废铁」怪兽的同调召唤不能使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c56746202.synlimit)
	c:RegisterEffect(e2)
	-- 其他的同调素材怪兽必须全部是「废铁」怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56746202,1))  --"是否使用「废铁奇美拉」作同调素材？"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SCRAP_CHIMERA)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c56746202.synlimit2)
	c:RegisterEffect(e3)
end
-- 过滤出自己墓地中可以特殊召唤的「废铁」调整怪兽
function c56746202.filter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择（Target阶段）
function c56746202.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56746202.filter(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己墓地是否存在至少1只符合条件的「废铁」调整怪兽
		and Duel.IsExistingTarget(c56746202.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「废铁」调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56746202.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表明该效果包含将选中的1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（Operation阶段）
function c56746202.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制此卡只能用于「废铁」怪兽的同调召唤
function c56746202.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x24)
end
-- 限制与此卡一起作为同调素材的其他怪兽必须全部是「废铁」怪兽
function c56746202.synlimit2(e,c)
	return not c:IsSetCard(0x24)
end
