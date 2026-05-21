--RUM－千死蛮巧
-- 效果：
-- 「升阶魔法-千死蛮巧」在1回合只能发动1张，这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。
-- ①：以自己以及对方的墓地的相同阶级的超量怪兽各1只以上为对象才能发动。比那些怪兽阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽从额外卡组特殊召唤，把作为对象的怪兽在下面重叠作为超量素材。
function c96142517.initial_effect(c)
	-- 「升阶魔法-千死蛮巧」在1回合只能发动1张，这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：以自己以及对方的墓地的相同阶级的超量怪兽各1只以上为对象才能发动。比那些怪兽阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽从额外卡组特殊召唤，把作为对象的怪兽在下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c96142517.cost)
	e1:SetTarget(c96142517.target)
	e1:SetOperation(c96142517.activate)
	c:RegisterEffect(e1)
end
-- 发动的Cost：检查本回合是否进行过特殊召唤，并注册本回合不能用这张卡的效果以外把怪兽特殊召唤的限制
function c96142517.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合自己是否进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 「升阶魔法-千死蛮巧」在1回合只能发动1张，这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：以自己以及对方的墓地的相同阶级的超量怪兽各1只以上为对象才能发动。比那些怪兽阶级高1阶的1只「混沌No.」怪兽或者「混沌超量」怪兽从额外卡组特殊召唤，把作为对象的怪兽在下面重叠作为超量素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96142517.sumlimit)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数：允许此卡自身的效果进行特殊召唤，阻止其他效果的特殊召唤
function c96142517.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetHandler()~=se:GetHandler()
end
-- 墓地目标超量怪兽的过滤条件：必须是超量怪兽，可以作为超量素材，可以成为效果对象，且额外卡组存在比其阶级高1阶的「混沌No.」或「混沌超量」怪兽
function c96142517.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsType(TYPE_XYZ) and c:IsCanOverlay() and c:IsCanBeEffectTarget(e)
		-- 检查额外卡组是否存在满足特殊召唤条件的、阶级比目标怪兽高1阶的怪兽
		and Duel.IsExistingMatchingCard(c96142517.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk+1)
end
-- 额外卡组特殊召唤怪兽的过滤条件：阶级符合要求，属于「混沌No.」或「混沌超量」怪兽，可以特殊召唤，且额外怪兽区域有空位
function c96142517.spfilter(c,e,tp,rk)
	return c:IsRank(rk) and c:IsSetCard(0x1048,0x1073) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外怪兽区域是否有可用于特殊召唤该怪兽的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 卡片组检查函数：所选怪兽的阶级必须全部相同
function c96142517.gcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 卡片组选择条件：必须包含自己和对方墓地的怪兽各至少1只，且额外卡组存在可特殊召唤的对应怪兽（处理了CNo.1000的特殊限制）
function c96142517.fselect(g,e,tp)
	if not g:IsExists(Card.IsControler,1,nil,tp) or not g:IsExists(Card.IsControler,1,nil,1-tp) then return false end
	-- 获取额外卡组中阶级为9的、可特殊召唤的「混沌No.」或「混沌超量」怪兽组
	local mg=Duel.GetMatchingGroup(c96142517.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,9)
	return not g:GetFirst():IsRank(8)
		-- 处理CNo.1000（混沌虚无齿轮齿轮）的特殊限制：如果额外卡组只有CNo.1000，则墓地必须包含「No.1000 梦幻虚神 尘埃之寰」
		or mg:IsExists(aux.NOT(Card.IsOriginalCodeRule),1,nil,6165656) or g:IsExists(Card.IsCode,1,nil,48995978)
end
-- 效果处理时额外卡组特殊召唤怪兽的过滤条件：满足基本条件，且符合CNo.1000的特殊召唤限制
function c96142517.spfilter2(c,e,tp,rk,tg)
	return c96142517.spfilter(c,e,tp,rk) and (not c:IsOriginalCodeRule(6165656) or tg:IsExists(Card.IsCode,1,nil,48995978))
end
-- 效果发动的准备阶段（Target）：选择自己和对方墓地相同阶级的超量怪兽各1只以上作为对象，并声明特殊召唤和移出墓地的操作信息
function c96142517.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取双方墓地中满足条件的超量怪兽
	local g=Duel.GetMatchingGroup(c96142517.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	if chkc then return false end
	if chk==0 then
		-- 设置卡片组选择的附加检查函数，限制所选怪兽必须阶级相同
		aux.GCheckAdditional=c96142517.gcheck
		local res=g:CheckSubGroup(c96142517.fselect,2,#g,e,tp)
		-- 重置卡片组选择的附加检查函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 在玩家选择对象前，再次设置卡片组选择的附加检查函数
	aux.GCheckAdditional=c96142517.gcheck
	local g1=g:SelectSubGroup(tp,c96142517.fselect,false,2,#g,e,tp)
	-- 在玩家选择对象后，重置卡片组选择的附加检查函数
	aux.GCheckAdditional=nil
	-- 将选择的墓地怪兽注册为效果的对象
	Duel.SetTargetCard(g1)
	local rk=g1:GetFirst():GetRank()
	e:SetLabel(rk)
	-- 设置操作信息：涉及墓地卡片离场
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,g1:GetCount(),0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段（Activate）：从额外卡组特殊召唤对应的怪兽，并将作为对象的墓地怪兽重叠作为其超量素材
function c96142517.activate(e,tp,eg,ep,ev,re,r,rp)
	local rk=e:GetLabel()
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local mg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if mg:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「混沌No.」或「混沌超量」怪兽
	local g=Duel.SelectMatchingCard(tp,c96142517.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rk+1,tg)
	local sc=g:GetFirst()
	if sc then
		local og=mg:Filter(Card.IsCanOverlay,nil)
		-- 将仍存在于墓地的对象怪兽重叠在特殊召唤的怪兽下面作为超量素材
		Duel.Overlay(sc,og)
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
