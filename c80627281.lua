--海晶乙女雪花
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的「海晶少女」连接怪兽被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。连接标记数量比那只怪兽少的1只「海晶少女」连接怪兽当作连接召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽只要在自己场上存在，不受对方的效果影响。
function c80627281.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的「海晶少女」连接怪兽被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。连接标记数量比那只怪兽少的1只「海晶少女」连接怪兽当作连接召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,80627281+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c80627281.target)
	e1:SetOperation(c80627281.activate)
	c:RegisterEffect(e1)
end
-- 过滤被战斗·效果破坏并送去墓地或除外的、原本在自己场上的「海晶少女」连接怪兽，且额外卡组存在连接标记数量比其少、可特殊召唤的「海晶少女」连接怪兽
function c80627281.spfilter1(c,e,tp)
	local lk=c:GetLink()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsPreviousSetCard(0x12b) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		-- 检查额外卡组是否存在至少1只连接标记数量比该怪兽少、且满足特殊召唤条件的「海晶少女」连接怪兽
		and lk>0 and Duel.IsExistingMatchingCard(c80627281.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lk)
end
-- 过滤额外卡组中连接标记数量比目标怪兽少、且可以当作连接召唤特殊召唤的「海晶少女」连接怪兽
function c80627281.spfilter2(c,e,tp,lk)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:GetLink()<lk
		-- 检查该卡是否可以当作连接召唤特殊召唤，且额外卡组怪兽出场所需的怪兽区域空格数大于0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的对象选择与合法性检测
function c80627281.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c80627281.spfilter1(chkc,e,tp) end
	-- 检查玩家是否受到必须作为连接素材等效果的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL)
		and eg:IsExists(c80627281.spfilter1,1,nil,e,tp) end
	if eg:GetCount()==1 then
		-- 当只有1只符合条件的怪兽被破坏时，直接将该怪兽设为效果的对象
		Duel.SetTargetCard(eg)
	else
		-- 提示玩家选择作为效果对象的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local g=eg:FilterSelect(tp,c80627281.spfilter1,1,1,nil,e,tp)
		-- 将玩家选择的怪兽设为效果的对象
		Duel.SetTargetCard(g)
	end
	-- 设置连锁的操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数，选择并特殊召唤怪兽，并赋予其不受对方效果影响的抗性
function c80627281.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否仍适应此效果，以及玩家是否仍满足连接素材限制，若不满足则结束处理
	if not tc:IsRelateToEffect(e) or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只连接标记数量比对象怪兽少的「海晶少女」连接怪兽
	local g=Duel.SelectMatchingCard(tp,c80627281.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetLink())
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽当作连接召唤以表侧表示特殊召唤，若特殊召唤成功则进行后续处理
	if Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽只要在自己场上存在，不受对方的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c80627281.immcon)
		e1:SetValue(c80627281.efilter)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
		tc:RegisterEffect(e1,true)
		tc:CompleteProcedure()
	end
end
-- 限制抗性生效的条件：该怪兽必须存在于自己的场上（由自己控制）
function c80627281.immcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 过滤不受影响的效果来源，使其仅不受对方玩家卡片效果的影响
function c80627281.efilter(e,te)
	return e:GetOwnerPlayer()~=te:GetOwnerPlayer()
end
