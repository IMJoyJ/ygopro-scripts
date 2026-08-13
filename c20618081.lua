--転生炎獣ファルコ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被送去墓地的场合，以自己墓地1张「转生炎兽」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
-- ②：这张卡在墓地存在的场合，以「转生炎兽 猎鹰」以外的自己场上1只「转生炎兽」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡从墓地特殊召唤。
function c20618081.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡被送去墓地的场合，以自己墓地1张「转生炎兽」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20618081,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20618081)
	e1:SetTarget(c20618081.settg)
	e1:SetOperation(c20618081.setop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的场合，以「转生炎兽 猎鹰」以外的自己场上1只「转生炎兽」怪兽为对象才能发动。那只怪兽回到持有者手卡，这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20618081,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,20618081)
	e2:SetTarget(c20618081.sptg)
	e2:SetOperation(c20618081.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果选择对象的过滤条件：从墓地中筛选「转生炎兽」魔法·陷阱卡，且该卡能够盖放到魔法与陷阱区域。
function c20618081.filter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的目标选择函数：先进行对象合法性/存在性判定，再提示玩家从自己墓地选择1张可盖放的「转生炎兽」魔法·陷阱卡作为对象，并登记离墓操作信息。
function c20618081.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c20618081.filter(chkc) end
	-- 效果发动条件判定：自己墓地存在至少1张符合filter的「转生炎兽」魔法·陷阱卡，且可以作为本效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c20618081.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要盖放的卡”的选择提示，用于后续从墓地选卡的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地的符合条件卡中选取1张，并将其登记为当前连锁效果的对象。
	local g=Duel.SelectTarget(tp,c20618081.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：对象卡将因本次效果离开墓地，使相关离墓判定（如王家长眠之谷等）能够正确应对。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ①效果的处理函数：取出此前选择的对象卡，若该卡仍与本效果关联，则将其盖放到自己场上。
function c20618081.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果的对象卡（从墓地选择的「转生炎兽」魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象魔法·陷阱卡里侧表示盖放到自己场上（仅盖放，不发动）。
		Duel.SSet(tp,tc)
	end
end
-- 定义②效果的对象过滤条件：表侧表示的「转生炎兽」怪兽，不能是「转生炎兽 猎鹰」自身，能够返回手牌，且返回后自己场上仍有可用怪兽区。
function c20618081.thfilter(c,tp)
	-- 判定对象怪兽：必须是表侧表示的「转生炎兽」怪兽、不是猎鹰本身、能返回手牌，并且它返回手牌后自己场上还有空格可供特殊召唤。
	return c:IsFaceup() and c:IsSetCard(0x119) and not c:IsCode(20618081) and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)
end
-- ②效果的目标与发动条件函数：chkc分支复核指定对象是否合法；chk==0分支检查墓地中的猎鹰能否特殊召唤，且自己场上存在可选的「转生炎兽」怪兽。
function c20618081.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20618081.thfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外确认存在至少1只满足thfilter的「转生炎兽」怪兽，可以作为②效果的对象。
		and Duel.IsExistingTarget(c20618081.thfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家显示“请选择要返回手牌的卡”的选择提示，用于后续选择怪兽的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上的符合条件的「转生炎兽」怪兽中选择1只，并登记为②效果的对象。
	local g=Duel.SelectTarget(tp,c20618081.thfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记操作信息：对象怪兽将因效果返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 登记操作信息：墓地的「转生炎兽 猎鹰」将通过此效果被特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：先让对象怪兽返回持有者手牌，确认返回成功且自身仍与效果关联后，再从墓地特殊召唤猎鹰。
function c20618081.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽（自己场上的那只「转生炎兽」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 处理条件判断：对象怪兽仍与效果关联，且成功因效果返回持有者手牌；同时猎鹰自身仍与效果关联，才继续特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) then
		-- 从墓地以表侧表示特殊召唤「转生炎兽 猎鹰」到tp的场上（前一步已确认其满足特殊召唤条件）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
